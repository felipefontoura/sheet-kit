// Checks for a built sheet. Run by scripts/build.sh; each check is one rule
// from AGENTS.md that someone used to catch by eye.
//
//   node check.mjs --pdf dist/x.pdf --fallback .build/fallback.pdf
//                  --format letter-landscape --png dist/png --ppi 144
//                  [--ref output/png] [--max-mean 0.5] [--links]
//   node check.mjs --slab .build/preview/1.5
import fs from "node:fs";
import path from "node:path";

import * as mupdf from "mupdf";
import { PNG } from "pngjs";

const FORMATS = { // points
  "letter-landscape": [792, 612],
  letter: [612, 792],
  "a4-landscape": [841.89, 595.28],
  a4: [595.28, 841.89],
};
const FAMILIES = ["Inter", "Newsreader", "JetBrainsMono"];
const SAFE = { top: 32, bottom: 28, x: 48 }; // px; typst/theme.typ `margin`
// Glyphs may overhang their box (an italic f's tail, a J's descender):
// typographically right, so the margin band starts this far out (px).
const OVERHANG = 2;

const args = process.argv.slice(2);
const opt = (k, d) => (args.includes(k) ? args[args.indexOf(k) + 1] : d);
const flag = (k) => args.includes(k);

let failed = 0;
function report(name, ok, detail = "", notes = []) {
  console.log(`   ${ok ? "✓" : "✗"} ${name.padEnd(24)} ${detail}`);
  for (const n of notes) console.log(`       ${n}`);
  if (!ok) failed++;
}

const open = (file) => mupdf.Document.openDocument(fs.readFileSync(file), "application/pdf");
const baseName = (f) => f.split("+").pop();
const house = (f) => FAMILIES.some((x) => baseName(f).startsWith(x));
function* lines(doc) {
  for (let i = 0; i < doc.countPages(); i++) {
    const st = JSON.parse(doc.loadPage(i).toStructuredText("preserve-whitespace").asJSON());
    for (const b of st.blocks) for (const l of b.lines ?? []) yield [i + 1, l];
  }
}
const readPng = (file) => PNG.sync.read(fs.readFileSync(file));
const pngs = (dir) => fs.readdirSync(dir).filter((f) => f.endsWith(".png")).sort();
const lum = (d, i) => (d[i] * 299 + d[i + 1] * 587 + d[i + 2] * 114) / 1000;

function checkPages(doc, fmt) {
  const [w, h] = FORMATS[fmt];
  const off = [];
  for (let i = 0; i < doc.countPages(); i++) {
    const [x0, y0, x1, y1] = doc.loadPage(i).getBounds();
    if (Math.abs(x1 - x0 - w) > 0.5 || Math.abs(y1 - y0 - h) > 0.5) off.push(i + 1);
  }
  report("page size", !off.length, `${doc.countPages()} pages, ${fmt}${off.length ? `; wrong on ${off}` : ""}`);
}

function checkFonts(doc) {
  const names = new Set();
  for (const [, l] of lines(doc)) names.add(baseName(l.font.name));
  const stray = [...names].filter((n) => !house(n)).sort();
  report("fonts", !stray.length, `${names.size} faces${stray.length ? `; stray ${stray}` : ", house families only"}`);
}

// With fallback on, a glyph the house fonts lack is set in a Typst fallback
// face. Name the page and the text that needed it.
function checkGlyphs(fallback) {
  const hits = [];
  for (const [p, l] of lines(fallback)) {
    if (!house(l.font.name) && l.text.trim()) hits.push(`p${p} "${l.text.trim()}" (${baseName(l.font.name)})`);
  }
  report("glyphs", !hits.length, hits.length ? "" : "every character in a house font", hits.slice(0, 12).map((h) => `missing: ${h}`));
}

// Nothing is painted in the margin band: every pixel there is the page
// ground. Ink-precise, so it catches text and shapes that overflow.
function checkSafeArea(dir, ppi) {
  const k = ppi / 96; // device px per px
  const bad = [];
  for (const f of pngs(dir)) {
    const { width: W, height: H, data: d } = readPng(path.join(dir, f));
    const g = [d[(2 * W + 2) * 4], d[(2 * W + 2) * 4 + 1], d[(2 * W + 2) * 4 + 2]];
    const t = Math.floor((SAFE.top - OVERHANG) * k);
    const b = H - Math.floor((SAFE.bottom - OVERHANG) * k);
    const x = Math.floor((SAFE.x - OVERHANG) * k);
    let n = 0, first = null;
    for (let y = 0; y < H; y++) {
      for (let xx = 0; xx < W; xx++) {
        if (y >= t && y < b && xx >= x && xx < W - x) continue;
        const i = (y * W + xx) * 4;
        if (Math.abs(d[i] - g[0]) + Math.abs(d[i + 1] - g[1]) + Math.abs(d[i + 2] - g[2]) > 24) {
          n++;
          first ??= [xx, y];
        }
      }
    }
    if (n) bad.push(`${f}: ${n} px, first at (${Math.round(first[0] / k)}, ${Math.round(first[1] / k)}) px`);
  }
  report("safe area", !bad.length, bad.length ? "" : "nothing painted in the margins", bad.map((b) => `outside: ${b}`));
}

function checkRegression(dir, ref, maxMean) {
  const rows = [];
  for (const f of pngs(ref)) {
    const nf = path.join(dir, f);
    if (!fs.existsSync(nf)) { rows.push([f, null, "missing"]); continue; }
    const a = readPng(path.join(ref, f)), b = readPng(nf);
    if (a.width !== b.width || a.height !== b.height) { rows.push([f, null, `size ${a.width}×${a.height} → ${b.width}×${b.height}`]); continue; }
    let sum = 0, moved = 0;
    for (let i = 0; i < a.data.length; i += 4) {
      const dd = Math.abs(Math.floor(lum(a.data, i)) - Math.floor(lum(b.data, i)));
      sum += dd;
      if (dd > 40) moved++;
    }
    const px = a.width * a.height;
    rows.push([f, sum / px, `${((moved / px) * 100).toFixed(2)}% px moved`]);
  }
  const extra = pngs(dir).filter((f) => !fs.existsSync(path.join(ref, f)));
  const worst = rows.filter(([, m]) => m === null || m > maxMean);
  const top = Math.max(0, ...rows.map(([, m]) => m ?? 0));
  report(
    "regression",
    !worst.length && !extra.length,
    `${rows.length} pages vs output/png, worst mean ${top.toFixed(3)}${extra.length ? `; new pages ${extra}` : ""}`,
    [
      ...worst.map(([f, m, note]) => `changed: ${f} mean ${m === null ? "-" : m.toFixed(3)} ${note}`),
      ...(worst.length || extra.length ? ["meant it? rebuild with --update-ref"] : []),
    ],
  );
}

async function checkLinks(doc, fetchThem) {
  const uris = new Set();
  for (let i = 0; i < doc.countPages(); i++) {
    for (const l of doc.loadPage(i).getLinks()) if (l.isExternal()) uris.add(l.getURI());
  }
  if (!fetchThem) return report("links", true, `${uris.size} in the PDF (--links to request them)`);
  const bad = [];
  for (const u of [...uris].sort()) {
    try {
      const r = await fetch(u, { redirect: "follow", signal: AbortSignal.timeout(15000), headers: { "User-Agent": "sheet-kit-check" } });
      if (r.status >= 400) bad.push(`${r.status} ${u}`);
    } catch (e) {
      bad.push(`${e.name} ${u}`);
    }
  }
  report("links", !bad.length, `${uris.size} requested`, bad.map((b) => `broken: ${b}`));
}

// Preview paints transparency groups (blurred shadows, some blend modes)
// as a box a shade darker than the ground: count pixels darker than it.
function checkSlab(dir) {
  const bad = [];
  const files = pngs(dir);
  for (const f of files) {
    const { width: W, height: H, data: d } = readPng(path.join(dir, f));
    const g = d[(2 * W + 2) * 4] + d[(2 * W + 2) * 4 + 1] + d[(2 * W + 2) * 4 + 2];
    let n = 0;
    for (let i = 0; i < d.length; i += 4) if (d[i] + d[i + 1] + d[i + 2] < g - 9) n++;
    const share = (n / (W * H)) * 100;
    if (share > 0.01) bad.push(`${f}: ${share.toFixed(2)}% darker than the ground`);
  }
  report("no Preview slabs", !bad.length, `${files.length} pages at ${path.basename(dir)}x`, bad.map((b) => `slab: ${b}`));
}

if (opt("--slab")) checkSlab(opt("--slab"));
if (opt("--pdf")) {
  const doc = open(opt("--pdf"));
  checkPages(doc, opt("--format", "letter-landscape"));
  checkFonts(doc);
  if (opt("--fallback")) checkGlyphs(open(opt("--fallback")));
  if (opt("--png")) {
    checkSafeArea(opt("--png"), Number(opt("--ppi", 144)));
    if (opt("--ref")) checkRegression(opt("--png"), opt("--ref"), Number(opt("--max-mean", 0.5)));
  }
  await checkLinks(doc, flag("--links"));
}
process.exit(failed ? 1 : 0);
