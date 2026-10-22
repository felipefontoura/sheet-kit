#import "/kit/typst/sheet.typ": *
#import "/data.typ": *

#show: sheet.with(section: "Colophon")

// Ends of the amber ramp the shared ink dict does not carry.

#let url = "https://felipefontoura.com/get/sdd-tools-cheatsheet/?utm_source=sheet-kit&utm_medium=referral&utm_campaign=concepts"

// 12-column grid, 16 px gutters: one column = (960 - 11 × 16) / 12 px.
#let G = 16
#let col = (960 - 11 * G) / 12
#let span(n) = (n * col + (n - 1) * G) * px

// JetBrains Mono draws its code ligatures through `calt`, which
// `ligatures: false` leaves on: switch it off wherever mono shows code.

// --- Row 1: headline (7 cols) and the QR tile (5 cols) ---------------------------
#let qr-tile = block(width: span(5), height: 184 * px, fill: ink.card, radius: 16 * px, inset: 20 * px, spacing: 0pt, grid(
  columns: (144 * px, 1fr),
  column-gutter: G * px,
  // amber-900 modules on amber-50: on-palette, about 9:1 contrast.
  block(width: 144 * px, height: 144 * px, fill: ink.amber-50, radius: 8 * px, inset: 8 * px, spacing: 0pt,
    tiaoma.qrcode(url, width: 128 * px, options: (fg-color: ink.amber-900, bg-color: ink.amber-50))),
  block(height: 144 * px, spacing: 0pt, {
    lbl("Scan or click")
    v(8 * px)
    para(sf("The free SDD tools cheatsheet.", size: 18, lh: 24))
    v(1fr)
    para(link(url, m([felipefontoura.com/get/\ sdd-tools-cheatsheet], size: 9.5, fill: ink.amber-400, lh: 14)))
  }),
))

#let headline = block(width: span(7), height: 184 * px, spacing: 0pt, {
  lbl("How this book was made")
  v(12 * px)
  // Optical alignment: Newsreader's side bearing sets the "S" 1 px in.
  move(dx: -1 * px, para(sf([Set in three voices,\ drawn by code.], size: 40, lh: 44)))
  v(1fr)
  block(width: span(6), para(ss("Each page of this book is one Typst file: data in, PDF out, in about a second. No browser, no layout tool, and no mark placed by hand.", size: 14, lh: 20, fill: ink.secondary)))
})

// --- Row 2: three families (3 cols each) and the index (3 cols) ----------------
// Every column opens the same way: a 40 px name on one shared baseline, a
// caps role line, then 22 px rows. The glyph wells share one height.
#let R = 22 // row pitch, px
// Text on a fixed baseline 6 px above the row's bottom, whatever the font:
// a row mixing Newsreader, Inter and JetBrains Mono shares one baseline.
#let on-base(body, font: sans, size: 12, fill: ink.paper, weight: 400, style: "normal", h: R, drop: 6) = box(width: 100%, height: h * px,
  place(left + bottom, dy: -drop * px, text(font: font, size: size * px, fill: fill, weight: weight, style: style,
    top-edge: "cap-height", bottom-edge: "baseline", body)))
#let name(body, font: serif, size: 40, fill: ink.paper, style: "normal") = box(width: 100%, height: 40 * px,
  align(left + bottom, move(dx: if font == serif { -1 * px } else { 0pt }, text(font: font, size: size * px, fill: fill, style: style, top-edge: "ascender", bottom-edge: "baseline", body))))
#let role(body) = {
  v(12 * px)
  para(m(upper(body), size: 9, fill: ink.amber-600, tr: 0.06em, lh: 12))
  v(12 * px)
}

#let weight-names = ("400": "Regular", "500": "Medium", "600": "SemiBold", "700": "Bold")
// One weight per row: the roman, its italic, the number right-aligned.
#let weight-row(font, w, italic, size) = grid(
  columns: (1fr, 1fr, 28 * px),
  align: (left, left, right),
  on-base(weight-names.at(str(w)), font: font, size: size, weight: w),
  if italic { on-base("Italic", font: font, size: size, weight: w, style: "italic") },
  on-base(align(right, str(w)), font: mono, size: 9, fill: ink.muted),
)

#let glyph-lines(lines, font: sans, size: 17) = stack(..lines.map(l => on-base(l, font: font, size: size, h: 28, drop: 8)))
#let well(glyphs, note) = block(width: 100%, height: 112 * px, fill: ink.elevated, radius: 10 * px, inset: 12 * px, spacing: 0pt, {
  glyphs
  v(1fr)
  para(m(note, size: 9, fill: ink.muted, lh: 12))
})

#let family(font, label, size, role-text, weights, glyphs, note) = block(width: span(3), height: 100%, spacing: 0pt, {
  name(label, font: font, size: size)
  role(role-text)
  stack(..weights.map(((w, it)) => weight-row(font, w, it, if font == mono { 12.5 } else { 14 })))
  v(1fr)
  well(glyphs, note)
})

#let index = block(width: span(3), height: 100%, spacing: 0pt, {
  name([Index], style: "italic", fill: ink.amber-400)
  role("Page · what it drew")
  stack(..(
    ("01", "Golden-angle spiral"),
    ("02", "Decision ladder"),
    ("03", "Glyphs · orbit · units"),
    ("04", "Metro map"),
    ("05", "Alluvial flows"),
    ("06", "Bubbles · timeline"),
    ("07", "State machine · code"),
    ("08", "Radar multiples"),
    ("09", "Long-read, drop cap"),
    ("10", "QR · specimen · palette"),
  ).map(((n, what)) => grid(
    columns: (28 * px, 1fr),
    on-base(n, font: mono, size: 9.5, fill: ink.amber-600),
    on-base(what, size: 12.5),
  )))
})

#let specimen = grid(
  columns: (span(3),) * 4,
  column-gutter: G * px,
  family(serif, "Newsreader", 40, "Headings · opsz 16", ((400, true), (500, true), (600, true)),
    glyph-lines(("Aa Gg Qq & fi fl", "0123456789"), font: serif, size: 20),
    "Production Type · OFL"),
  family(sans, "Inter", 40, "Body and UI · opsz 14", ((400, true), (500, true), (600, true), (700, false)),
    glyph-lines(("→ ← ↑ ↓ ↗ ● ○ ✓", "≈ ≠ ≤ ≥ ∞ π ★"), font: sans, size: 17),
    "Rasmus Andersson · OFL"),
  family(mono, "JetBrains Mono", 26, "Labels and data", ((400, true), (500, false), (700, false)),
    nocalt(glyph-lines(("0O 1lI {} []", "-> => != // ~$"), font: mono, size: 17)),
    "JetBrains · OFL · calt off"),
  index,
)

// --- Row 3: the palette, four chips per row on the same 3-column grid ----------
#let chip(name, c) = block(width: span(3), spacing: 0pt, {
  set par(leading: 0pt)
  box(width: 20 * px, height: 20 * px, radius: 4 * px, fill: c, baseline: 5 * px,
    stroke: if name in ("bg", "inverse") { 1 * px + ink.border } else { none },
    outset: if name in ("bg", "inverse") { -0.5 * px } else { 0pt })
  h(8 * px)
  m(name, size: 9.5, fill: ink.secondary, lh: 20)
  h(1fr)
  m(upper(c.to-hex()), size: 9, fill: ink.muted, lh: 20)
})
#let shown = ("bg", "elevated", "card", "soft", "border", "border-strong", "paper", "secondary", "muted", "inverse", "amber-300", "amber-400", "amber-500", "amber-600", "amber-700")
#let palette = grid(
  columns: (span(3),) * 4,
  column-gutter: G * px,
  row-gutter: 8 * px,
  // The tokens these pages draw with, in the order the page was set for.
  ..shown.map(k => chip(k, ink.at(k))),
)

// --- Page ------------------------------------------------------------------------
#grid(columns: (span(7), span(5)), column-gutter: G * px, headline, qr-tile)
#v(32 * px)
#block(height: 292 * px, spacing: 0pt, specimen)
#v(32 * px)
#lbl("Palette · the ink tokens")
#v(12 * px)
#palette
#v(1fr)
#para(ss("Felipe Fontoura, AI Engineer", size: 12, lh: 16, weight: 600) + h(8 * px) + m("·", size: 10, lh: 16, fill: ink.muted) + h(8 * px) + link("https://felipefontoura.com", m("felipefontoura.com", size: 10, lh: 16, fill: ink.amber-400)) + h(1fr) + m("sheet-kit · Typst 0.15.1 · checked " + checked, size: 9, lh: 16, fill: ink.muted))
