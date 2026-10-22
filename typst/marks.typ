// Marks: the small parts infographics are built from. Badges, arrows,
// textures, glows, and the joins between shapes (where seams come from).
#import "@preview/cetz:0.5.3"
#import "theme.typ": *
#import "type.typ": *

// A cetz canvas in px units: 1 unit = 1 px, origin bottom-left, y up.
#let canvas(body) = cetz.canvas(length: 1 * px, body)

// An invisible rect that fixes a canvas's bounding box, so a drawing occupies
// exactly w × h px whatever its marks reach (cetz sizes canvases to content).
#let frame(w, h) = {
  import cetz.draw: *
  rect((0, 0), (w, h), stroke: none, fill: none)
}

// Numbered marker for keys and annotations.
#let badge(n, fill: ink.amber-500, size: 15) = box(width: size * px, height: size * px, radius: size / 2 * px, fill: fill, align(center + horizon, tx(str(n), font: mono, size: 9, lh: 12, fill: ink.inverse, weight: 700)))

// Straight arrow from (x1, y1) to (x2, y2), px, inside a placed container.
#let arrow(x1, y1, x2, y2, fill: ink.border-strong, head: true) = {
  let dx = x2 - x1
  let dy = y2 - y1
  let len = calc.sqrt(dx * dx + dy * dy)
  let ux = dx / len
  let uy = dy / len
  let hl = 6 // head length, px
  let hw = 3.5 // head half width, px
  let ex = if head { x2 - ux * hl } else { x2 }
  let ey = if head { y2 - uy * hl } else { y2 }
  place(top + left, line(start: (x1 * px, y1 * px), end: (ex * px, ey * px), stroke: (paint: fill, thickness: 2 * px, cap: "round")))
  if head {
    place(top + left, polygon(
      fill: fill,
      (x2 * px, y2 * px),
      ((ex - uy * hw) * px, (ey + ux * hw) * px),
      ((ex + uy * hw) * px, (ey - ux * hw) * px),
    ))
  }
}

// Textures that encode a category without a new colour: a diagonal hatch
// and a dot screen. Lay them over a flat fill.
#let hatch(paint: ink.secondary.transparentize(35%), size: 6, thickness: 1) = tiling(
  size: (size * px, size * px),
  line(start: (0pt, size * px), end: (size * px, 0pt), stroke: thickness * px + paint),
)
#let screen(paint: ink.secondary.transparentize(20%), size: 5, dot: 0.9) = tiling(
  size: (size * px, size * px),
  place(dx: size / 2 * px - 0.5 * px, dy: size / 2 * px - 0.5 * px, circle(radius: dot * px, fill: paint)),
)

// A soft radial glow: amber light behind a mark, fading to nothing.
#let glow(paint: ink.amber-500, from: 55%) = gradient.radial(paint.transparentize(from), paint.transparentize(100%))

// Joins. Two shapes that only touch leave an antialiasing hairline in
// Preview (the ground shows through the shared edge). So shapes that meet
// overlap: the one underneath tucks this far (px) under the one on top.
#let tuck = 2

// A flow ribbon from (xa, ya1..ya2) to (xb, yb1..yb2), canvas px, y up: two
// cubic Béziers with flat ends. It tucks under the bars or blocks it joins,
// so draw it before them. `paint` may be a gradient; `over` a texture.
#let ribbon(xa, ya1, ya2, xb, yb1, yb2, paint: none, edge: none) = {
  import cetz.draw: *
  let (xa, xb) = (xa - tuck, xb + tuck)
  let k = (xb - xa) / 2
  merge-path(close: true, fill: paint, stroke: edge, {
    bezier((xa, ya1), (xb, yb1), (xa + k, ya1), (xb - k, yb1))
    line((xb, yb1), (xb, yb2))
    bezier((xb, yb2), (xa, ya2), (xb - k, yb2), (xa + k, ya2))
  })
}

// A row of boxes joined by one connector line. The line runs under the
// whole row, from the first box to the last, so it reads unbroken: boxes
// cover it, and hollow markers in the row should be filled with the ground
// colour so it stops at their edge. `height` is the row's line box (px).
#let connected(parts, height: 18, paint: ink.border-strong, thickness: strokes.guide) = {
  let row = stack(dir: ltr, ..parts)
  context {
    let w = measure(row).width
    box(width: w, height: height * px, {
      place(horizon, line(length: w, stroke: thickness + paint))
      row
    })
  }
}
