// Text that behaves like CSS: a font size and a line height in px, the
// baseline where a browser puts it. Every run of text on a sheet goes
// through `tx` (or one of its voices), so pages ported from HTML match.
#import "theme.typ": *

// CSS centres the glyph box in the line box. These edges do the same, so a
// line is exactly `lh` px tall and the baseline sits where Chrome puts it.
#let edges(font, size, lh) = {
  let (a, d) = metrics.at(font)
  let shift = (a - d) / 2 * size * px
  (top-edge: lh * px / 2 + shift, bottom-edge: -(lh * px / 2 - shift))
}

// Distance (px) from the top of a line box to the baseline is
// lh/2 + (a - d)/2 * size; this is its complement, used to line up the
// baselines of two lines set in different fonts or sizes.
#let base-gap(font, size, lh) = {
  let (a, d) = metrics.at(font)
  lh / 2 - (a - d) / 2 * size
}

// A run of text styled like a CSS element (font, size and line height in px).
#let tx(
  body,
  font: sans,
  size: 12,
  lh: 16,
  fill: ink.paper,
  weight: 400,
  tracking: 0em,
  caps: false,
  style: "normal",
) = {
  let e = edges(font, size, lh)
  text(
    font: font,
    size: size * px,
    fill: fill,
    weight: weight,
    tracking: tracking,
    style: style,
    // Code is set without ligatures. JetBrains Mono's code ligatures
    // (-> != ==) live in `calt`, not `liga`, so both go off for mono.
    ligatures: font != mono,
    features: if font == mono { (calt: 0) } else { (:) },
    top-edge: e.top-edge,
    bottom-edge: e.bottom-edge,
    if caps { upper(body) } else { body },
  )
}

// Turn off `calt` for a stretch of content set outside `tx` (raw blocks).
#let nocalt(body) = {
  set text(features: (calt: 0))
  body
}

// CSS's strut: every line box is at least as tall as the parent's font at
// `line-height: normal`. A zero-width space in that font reproduces it.
#let strut(font: sans, size: 16) = {
  let (a, d) = metrics.at(font)
  tx("\u{200B}", font: font, size: size, lh: (a + d) * size)
}

// A paragraph block: lines exactly `lh` apart, optimized line breaks.
#let para(body, ..args) = block(spacing: 0pt, {
  set par(leading: 0pt, spacing: 0pt, linebreaks: "optimized", justify: false)
  tx(body, ..args)
})

// The three voices with chart-friendly defaults; lh follows size unless set.
#let m(body, size: 10, fill: ink.secondary, weight: 400, tr: 0em, lh: none) = tx(body, font: mono, size: size, lh: if lh == none { size * 1.3 } else { lh }, fill: fill, weight: weight, tracking: tr)
#let sf(body, size: 14, fill: ink.paper, style: "normal", weight: 400, lh: none) = tx(body, font: serif, size: size, lh: if lh == none { size * 1.2 } else { lh }, fill: fill, style: style, weight: weight)
#let ss(body, size: 12, fill: ink.paper, weight: 400, lh: none, style: "normal") = tx(body, font: sans, size: size, lh: if lh == none { size * 1.35 } else { lh }, fill: fill, weight: weight, style: style)

// Mono caps labels: `eyebrow` for running heads, `lbl` for panel kickers.
#let eyebrow(body, fill: ink.secondary) = tx(body, font: mono, size: 12, lh: 16, tracking: 0.06em, caps: true, fill: fill)
#let lbl(body, fill: ink.amber-600) = para(body, font: mono, size: 12, lh: 14, tracking: 0.06em, caps: true, fill: fill)

// Inline code inside a sans paragraph of line height `lh`. Set as mono text,
// not `raw`: Typst's raw element carries its own font (DejaVu Sans Mono),
// which would win over the house mono. Quotes stay straight, as typed.
#let code(body, lh: 17, size: 11.5) = {
  set smartquote(enabled: false)
  tx(body, font: mono, size: size, lh: lh, fill: ink.paper)
}

#let pad2(n) = if n < 10 { "0" + str(n) } else { str(n) }
