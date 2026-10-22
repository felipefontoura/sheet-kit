#import "/kit/typst/sheet.typ": *
#import "/data.typ": *

#show: sheet.with(section: "Ecosystem")

// Layout (px). Content box 960 × 720; panels inset 20; gutters 16.
#let (gut, ins) = (16, 20)
#let (left-w, right-w) = (548, 960 - 548 - 16)
#let (row1, row2) = (420, 232)

// Stroke roles come from the kit: strokes.guide 1 px, .data 1.5 px, .emph 2 px.
#let (guide, data-line, emph) = (strokes.guide, strokes.data, strokes.emph)

// --- Data (lib/data.typ) --------------------------------------------------------
#let starred = tools.filter(t => t.stars != none).sorted(key: t => -t.stars)
#let total-stars = starred.map(t => t.stars).sum()
#let ink-of = tool-ink(ink)
#let at-run = (:)
#for r in run { at-run.insert(r.name, r.version) }
// One decimal, always: 303.0k, not 303k.
#let k1(x) = {
  let r = calc.round(x, digits: 1)
  let t = str(r)
  if t.contains(".") { t } else { t + ".0" }
}
#let oct-day(iso) = int(iso.slice(8, 10))
#let weekday(d) = calc.rem(d + 2, 7) // 1 Oct 2026 is a Thursday; 0 = Monday

// Panel heads with a 1.25 line height, the note on the title's baseline.
#let head-row(kicker, title, note: none, size: 16) = panel-head(kicker, title, size: size, lh: size * 1.25, note: note)

// --- Hero: packed bubbles (area ∝ stars) ----------------------------------------
#let k = 5.2
#let rad(s) = k * calc.sqrt(s)
#let tangent(a, b, r, g: 6, side: 1) = {
  let (ax, ay, ar) = a
  let (bx, by, br) = b
  let d = calc.sqrt(calc.pow(bx - ax, 2) + calc.pow(by - ay, 2))
  let (da, db) = (ar + r + g, br + r + g)
  let along = (da * da - db * db + d * d) / (2 * d)
  let off = calc.sqrt(calc.max(da * da - along * along, 0))
  let (ux, uy) = ((bx - ax) / d, (by - ay) / d)
  (ax + ux * along - uy * off * side, ay + uy * along + ux * off * side, r)
}

#let hero-w = left-w - 2 * ins  // 508
#let hero-h = 276
#let hero = canvas({
  import cetz.draw: *
  frame(hero-w, hero-h)
  // Cluster: Superpowers, Spec Kit to its right, the two smaller below.
  let sp = (279, 171, rad(303.0))
  let sk = (sp.at(0) + sp.at(2) + rad(142.3) + 6, sp.at(1), rad(142.3))
  let os = tangent(sp, sk, rad(72.6), side: -1)
  let bm = tangent(sp, os, rad(54.0), side: -1)
  circle((sp.at(0), sp.at(1)), radius: sp.at(2) + 12, fill: gradient.radial(ink.amber-500.transparentize(88%), ink.amber-500.transparentize(100%)), stroke: none)
  for (name, (x, y, r)) in (("Superpowers", sp), ("Spec Kit", sk), ("OpenSpec", os), ("BMAD", bm)) {
    let t = starred.find(t => t.name == name)
    let c = ink-of.at(name)
    let light = name == "Superpowers"
    circle((x, y), radius: r, fill: if light { ink.soft } else { c }, stroke: data-line + c)
    // Texture: a dotted ring every 50k stars, so area reads as scale.
    for i in range(1, calc.floor(t.stars / 50) + 1) {
      let ri = rad(i * 50)
      if ri < r - 6 { circle((x, y), radius: ri, fill: none, stroke: (paint: if light { ink.border-strong } else { ink.inverse.transparentize(70%) }, thickness: guide, dash: "dotted")) }
    }
    let fg = if light { ink.paper } else { ink.inverse }
    let size = calc.round(calc.min(28, r / 3.2))
    content((x, y + 4), anchor: "south", sf(name, size: size, fill: fg, lh: size))
    content((x, y - 4), anchor: "north", m(k1(t.stars) + "k · " + str(calc.round(t.stars / total-stars * 100)) + "%", size: if r > 50 { 11 } else { 9 }, fill: fg, weight: 700, lh: 12))
  }
  // Annotation: Superpowers outweighs the other three together.
  let a = 148deg
  let (px0, py0) = (sp.at(0) + sp.at(2) * calc.cos(a), sp.at(1) + sp.at(2) * calc.sin(a))
  line((px0, py0), (px0 - 24, py0 + 24), (176, py0 + 24), stroke: guide + ink.amber-500)
  circle((px0, py0), radius: 2.5, fill: ink.amber-500, stroke: none)
  content((172, py0 + 32), anchor: "east", m("MORE THAN THE", size: 9, fill: ink.amber-400, tr: 0.06em, lh: 12))
  content((172, py0 + 20), anchor: "east", m("OTHER THREE", size: 9, fill: ink.amber-400, tr: 0.06em, lh: 12))
  content((172, py0 + 4), anchor: "east", m("303.0k vs 268.9k", size: 9, fill: ink.secondary, lh: 12))
  // Ghost marks: tools with no public star count, never sized from a guess.
  for (i, name) in ("Kiro", "sdd-kit").enumerate() {
    let (gx, gy) = (16, 184 - i * 44)
    circle((gx, gy), radius: 16, fill: none, stroke: (paint: ink.border-strong, thickness: guide, dash: "dashed"))
    content((gx, gy), m("?", size: 11, fill: ink.muted, weight: 700, lh: 12))
    content((gx + 24, gy + 6), anchor: "west", m(name, size: 10, fill: ink.secondary, weight: 500, lh: 12))
    content((gx + 24, gy - 8), anchor: "west", m("no public count", size: 8.5, fill: ink.muted, lh: 12))
  }
  // Scale key: nested circles on one baseline, labels to the right.
  let kx = 52
  for (v, lab) in ((100, "100k"), (50, "50k"), (10, "10k")) {
    let r = rad(v)
    circle((kx, r), radius: r, fill: none, stroke: guide + ink.border-strong)
    line((kx, 2 * r), (kx + rad(100) + 8, 2 * r), stroke: (paint: ink.border, thickness: guide, dash: "dotted"))
    content((kx + rad(100) + 12, 2 * r), anchor: "west", m(lab, size: 9, fill: ink.secondary, lh: 12))
  }
})

// --- Lollipop: named agent integrations ------------------------------------------
#let lol-w = right-w - 2 * ins // 356
#let counted = tools.filter(t => t.agents != none).sorted(key: t => -t.agents)
#let uncounted = tools.filter(t => t.agents == none and t.name != "AGENTS.md").map(t => t.name)
#let lollipop = canvas({
  import cetz.draw: *
  let (x0, pitch) = (80, 24)
  let w = lol-w - x0 - 32
  let h = counted.len() * pitch + 16
  frame(lol-w, h)
  let X(v) = x0 + v / 50 * w
  for v in (0, 10, 20, 30, 40, 50) {
    line((X(v), 16), (X(v), h), stroke: guide + ink.soft)
    content((X(v), 12), anchor: "north", m(str(v), size: 8.5, fill: ink.muted, lh: 12))
  }
  for (i, t) in counted.enumerate() {
    let y = h - (i + 0.5) * pitch
    content((x0 - 12, y), anchor: "east", m(t.name, size: 10, fill: ink.paper, lh: 12))
    line((X(0), y), (X(t.agents), y), stroke: (paint: ink-of.at(t.name), thickness: emph, cap: "round"))
    circle((X(t.agents), y), radius: 5, fill: ink-of.at(t.name), stroke: none)
    content((X(t.agents) + 12, y), anchor: "west", m(str(t.agents), size: 11, fill: ink.paper, weight: 700, lh: 12))
  }
})

// --- Ledger: versions at the run and today -----------------------------------------
#let ledger = {
  let cols = (92 * px, 1fr, 1fr, 52 * px)
  let row(cells, fill: none) = block(width: 100%, fill: fill, radius: 6 * px, inset: (x: 8 * px, y: 4 * px), grid(columns: cols, column-gutter: 8 * px, align: (left + horizon, left + horizon, left + horizon, right + horizon), ..cells))
  let hd(t) = m(upper(t), size: 8.5, fill: ink.muted, tr: 0.06em, lh: 12)
  row((hd("tool"), hd("at the run"), hd("on 21 Oct"), hd("licence")))
  for (i, t) in tools.filter(x => x.name != "AGENTS.md").enumerate() {
    let was = at-run.at(t.name, default: none)
    let now = if t.name == "Kiro" { "IDE 1.4.10" } else { t.version }
    let moved = was != none and was != now
    row((
      m(t.name, size: 10, fill: ink.paper, weight: 500, lh: 12),
      m(if was == none { "not run" } else { was }, size: 10, fill: if was == none { ink.muted } else { ink.secondary }, lh: 12),
      m((if moved { "→ " } else { "" }) + now, size: 10, fill: if moved { ink.amber-400 } else { ink.paper }, weight: if moved { 700 } else { 400 }, lh: 12),
      m(if t.license == "proprietary" { "closed" } else { t.license }, size: 10, fill: ink.secondary, lh: 12),
    ), fill: if calc.even(i) { ink.elevated } else { none })
  }
}

// --- Calendar strip: October 2026 ----------------------------------------------------
#let cal-w = 960 - 2 * ins // 920
#let releases = starred.map(t => (day: oct-day(t.released), tool: t.name, version: t.version)).sorted(key: r => r.day)
#let calendar = canvas({
  import cetz.draw: *
  let h = 128
  frame(cal-w, h)
  let (gap, ch, base) = (4, 32, 20)
  let cw = (cal-w - 30 * gap) / 31
  let X(d) = (d - 1) * (cw + gap)
  let C(d) = X(d) + cw / 2
  let letters = ("M", "T", "W", "T", "F", "S", "S")
  let (r0, r1) = (releases.first().day, releases.last().day)
  rect((X(r0) - 4, base - 4), (X(r1) + cw + 4, base + ch + 4), radius: 8, fill: ink.amber-500.transparentize(90%), stroke: (paint: ink.amber-700, thickness: guide, dash: "dashed"))
  for d in range(1, 32) {
    let wd = weekday(d)
    let (is-run, is-check) = (d == 13, d == 21)
    let rel = releases.find(r => r.day == d)
    let fill = if is-run { ink.amber-500 } else if rel != none { ink.soft } else if wd >= 5 { ink.bg } else { ink.elevated }
    rect((X(d), base), (X(d) + cw, base + ch), radius: 5, fill: fill, stroke: if is-check { emph + ink.amber-400 } else { none })
    let fg = if is-run { ink.inverse } else { none }
    content((C(d), base + 24), m(letters.at(wd), size: 7.5, fill: if fg != none { fg } else { ink.muted }, lh: 8))
    content((C(d), base + 10), m(str(d), size: 10, fill: if fg != none { fg } else if rel != none or is-check { ink.paper } else { ink.secondary }, weight: if is-run or rel != none { 700 } else { 400 }, lh: 12))
  }
  // Release labels: two tiers so stems never cross a label.
  let tier = ("10": 1, "14": 2, "17": 2, "19": 1)
  for r in releases {
    let x = C(r.day)
    let t = tier.at(str(r.day), default: 1)
    let y0 = if t == 1 { 68 } else { 100 }
    circle((x, base + ch + 8), radius: 4, fill: ink-of.at(r.tool), stroke: none)
    line((x, base + ch + 12), (x, y0 + 24), stroke: guide + ink.border-strong)
    content((x + 8, y0 + 18), anchor: "west", sf(r.tool, size: 13, lh: 14))
    content((x + 8, y0 + 4), anchor: "west", m("v" + r.version, size: 9, fill: ink.secondary, lh: 12))
  }
  // One line of notes under the strip.
  let note(x, anchor, txt) = content((x, 6), anchor: anchor, m(txt, size: 8.5, fill: ink.amber-400, tr: 0.06em, lh: 12))
  note(X(r0) - 8, "east", "4 RELEASES IN 10 DAYS")
  note(C(13) - 4, "west", "THE RUN · 4 TOOLS, 1 BRIEF")
  note(C(21) - 4, "west", "RE-CHECKED · EVERY COMMAND, LIVE")
})

// --- Page --------------------------------------------------------------------------
#para(sf("572k stars, four repos, four releases in ten days.", size: 32, lh: 36) + h(1fr) + m("GitHub stars and releases · " + checked, size: 10, fill: ink.secondary, lh: 12))
#v(16 * px)
#grid(
  columns: (left-w * px, right-w * px),
  rows: (row1 * px, row2 * px),
  column-gutter: gut * px,
  row-gutter: gut * px,
  tile(inset: ins, {
    panel-head("Packed bubbles", "Where the attention went.")
    v(8 * px)
    para(ss("Each circle's area is a repo's GitHub stars.", size: 12, fill: ink.secondary, lh: 16))
    v(16 * px)
    hero
    v(1fr)
    source("Stars via gh api, " + checked + ". Four repos, 571.9k in all.")
  }),
  grid(rows: (168 * px, 236 * px), row-gutter: gut * px,
    tile(inset: ins, {
      head-row("Lollipop", "Agents each tool names.")
      v(12 * px)
      lollipop
      v(1fr)
      source("Not counted: " + uncounted.join(", ") + ".")
    }),
    tile(inset: ins, {
      head-row("Ledger", "What moved since the run.", note: "→ = new release")
      v(12 * px)
      ledger
    }),
  ),
  grid.cell(colspan: 2, tile(inset: ins, {
    head-row("Calendar strip · October 2026", "Three of four shipped after the run.", note: "weekends dark · dot = release · amber = the run")
    v(1fr)
    calendar
  })),
)
