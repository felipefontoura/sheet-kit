// The page and its frames: the sheet, its running head, the headline row,
// panels and their heads. Spacing is explicit everywhere (v() in px, like the
// CSS gaps it ports); blocks carry no implicit spacing.
#import "theme.typ": *
#import "type.typ": *

// The material's settings (sheet.config.json at the project root): the
// running head's label and check date, and the page format.
#let config = json("/sheet.config.json")

// `--input fallback=true` lets Typst substitute missing glyphs, so
// scripts/check.mjs can find them (a fallback face shows up in the PDF).
// Off by default: with the house fonts only, a missing glyph would
// otherwise change the face silently.
#let check-fallback = sys.inputs.at("fallback", default: "false") == "true"

// Page number and count. In the book, the page counter; for one page built
// alone, build.sh passes `--input page=NN`. The count comes from build.sh
// (`--input total=N`, the number of pages/*.typ).
#let page-total = int(sys.inputs.at("total", default: "1"))
#let page-number() = if "page" in sys.inputs { int(sys.inputs.page) } else { counter(page).get().first() }

// The running head every sheet carries: label · section, and the check date.
#let header(label: "", section: "", checked: "", n: auto, total: auto) = grid(
  columns: (1fr, auto),
  align: (left + bottom, right + bottom),
  para(tx(label, font: mono, size: 12, lh: 16, tracking: 0.06em, caps: true, fill: ink.amber-600) + eyebrow(" · " + section)),
  context para(eyebrow(
    "Checked " + checked + " · "
      + pad2(if n == auto { page-number() } else { n }) + " / "
      + pad2(if total == auto { page-total } else { total }),
  )),
)

// A sheet: one fixed-size page, dark ground, the running head, then the body.
// Use as `#show: sheet.with(section: "…")`: label, check date and format come
// from sheet.config.json, the page number and count from the build. A page
// file compiles alone (build.sh --page NN) and inside the book.
#let sheet(
  body,
  section: "",
  label: config.at("label", default: ""),
  checked: config.at("checked", default: ""),
  n: auto,
  total: auto,
  gap: 20,
  format: config.at("format", default: "letter-landscape"),
) = {
  let (w, h) = formats.at(format)
  set page(width: w, height: h, margin: (top: margin.top * px, bottom: margin.bottom * px, x: margin.x * px), fill: ink.bg)
  set text(font: sans, fill: ink.paper, fallback: check-fallback)
  // Raw blocks in the house mono too (Typst's default is DejaVu Sans Mono),
  // without code ligatures.
  show raw: set text(font: mono, features: (calt: 0))
  set block(spacing: 0pt)
  block(width: 100%, height: 100%, spacing: 0pt, {
    header(label: label, section: section, checked: checked, n: n, total: total)
    v(gap * px)
    body
  })
}

// The headline row: a serif headline and a mono note on one shared baseline
// (one line of text, so the baselines can't drift apart). The note's line box
// (`note-lh`) stays inside the title's: two fonts with different metrics on
// one line at the same line height make the line taller than `lh` (by ~4 px
// here), and then the page's arithmetic is off.
#let headline(title, note: none, size: 32, lh: 36, note-size: 10.5, note-fill: ink.secondary, note-lh: 12) = para(
  tx(title, font: serif, size: size, lh: lh, tracking: -0.02em)
    + if note != none { h(1fr) + m(note, size: note-size, fill: note-fill, lh: note-lh) },
)

// A surface card. No shadows: a blurred shadow prints as a transparency
// group, which Preview paints as a dark slab behind the card.
#let tile(body, inset: 20, fill: ink.card, radius: 16) = block(width: 100%, height: 100%, fill: fill, radius: radius * px, inset: inset * px, spacing: 0pt, body)

// A panel's opening: mono kicker, serif title, and an optional note that
// shares the title's baseline. `note` is a string (set small and muted) or
// content. The note's line box is smaller than the title's, so it never
// changes the row's height.
#let panel-head(kicker, title, size: 18, lh: none, note: none) = {
  lbl(kicker)
  v(4 * px)
  let l = if lh == none { size * 1.22 } else { lh }
  let n = if note == none { none } else if type(note) == str { m(note, size: 9, fill: ink.muted, lh: 12) } else { note }
  para(sf(title, size: size, lh: l) + if n != none { h(1fr) + n })
}

// The foot of a panel: a source or reading note.
#let source(body) = para(m(body, size: 9, fill: ink.muted))

// A box placed at (x, y) px from the top-left of its container.
#let at(x, y, body) = place(top + left, dx: x * px, dy: y * px, body)
