#import "/kit/typst/sheet.typ": *
#import "/data.typ": *

#show: sheet.with(section: "Concept book")

// The hero: the 13 Oct run as a sunflower. 1,007 dots, one per second of the
// four runs, laid on a phyllotaxis spiral (golden angle). The fastest run sits
// at the centre and each slower one rings it, so the bands are the runs.
#let order = run.sorted(key: r => r.time) // Superpowers, BMAD, OpenSpec, Spec Kit
// Lightness steps so the four rings read apart: paper at the core, then
// amber 300, 600, 800 outward.
#let shade = (
  "Superpowers": ink.paper,
  "BMAD": ink.amber-300,
  "OpenSpec": ink.amber-600,
  "Spec Kit": rgb("#845f15"), // amber-800
)
#let total = run.map(r => r.time).sum()
#let R = 196 // outer radius of the dots, px
#let gap = 9 // empty ring between two runs, px
#let c = (R - 3 * gap) / calc.sqrt(total)
#let golden = 137.50776deg

// Where each run starts and ends on the spiral (dot index).
#let bands = {
  let acc = 0
  let out = ()
  for (k, r) in order.enumerate() {
    out.push((name: r.name, time: r.time, from: acc, to: acc + r.time, k: k))
    acc += r.time
  }
  out
}

// Text set along an arc, one rotated glyph at a time (mono: fixed advance),
// centred on `centre`. On the bottom arc the glyphs turn so they stay upright.
#let arc-text(body, radius, centre: 90deg, size: 8.5, color: ink.muted) = {
  import cetz: draw
  import draw: *
  let chars = body.clusters()
  let adv = 0.6 * size + 0.1 * size // JetBrains Mono advance + tracking
  let step = adv / radius * 1rad
  let span = (chars.len() - 1) * step
  let bottom = calc.sin(centre) < 0
  for (i, ch) in chars.enumerate() {
    let a = if bottom { centre - span / 2 + i * step } else { centre + span / 2 - i * step }
    content((radius * calc.cos(a), radius * calc.sin(a)), angle: if bottom { a + 90deg } else { a - 90deg },
      text(font: mono, size: size * px, fill: color, ch))
  }
}

#let sunflower = canvas({
  import cetz: draw
  import draw: *
  // Glow under the centre.
  circle((0, 0), radius: R + 46, fill: gradient.radial(ink.amber-600.transparentize(80%), ink.amber-600.transparentize(100%)), stroke: none)
  // The dots: index i sits at sqrt(i) (equal area per dot), each later run
  // pushed out by one gap so the runs separate into rings.
  for b in bands {
    for i in range(b.from, b.to) {
      let r = c * calc.sqrt(i + 0.5) + b.k * gap
      let a = i * golden
      let size = 2.0 + 1.6 * r / R
      circle((r * calc.cos(a), r * calc.sin(a)), radius: size, fill: shade.at(b.name), stroke: none)
    }
  }
  // Outer hairline and the caption ring.
  circle((0, 0), radius: R + 14, stroke: (paint: ink.border, thickness: 0.8 * px), fill: none)
  arc-text("1,007 SECONDS · FOUR TOOLS · ONE BRIEF · 13 OCT 2026", R + 26, centre: 90deg)
  arc-text("ONE DOT PER SECOND · THE FASTEST RUN AT THE CORE", R + 26, centre: 270deg)
})

#let contents = (
  ("02", "Pick a tool", "decision ladder"),
  ("03", "The run, drawn", "glyphs · orbit · units"),
  ("04", "Every command, one map", "metro map"),
  ("05", "Where the gate lives, as flows", "alluvial"),
  ("06", "The ecosystem", "packed bubbles · timeline"),
  ("07", "The gate, engineered", "state machine · code"),
  ("08", "Shapes of a run", "radar · small multiples"),
  ("09", "Where approval lives", "editorial long-read"),
  ("10", "Colophon", "type · palette · QR"),
)

// One paragraph line per row, so number, title, leader and technique share
// the baseline exactly (separate boxes would each sit on their own).
#let leader = box(width: 1fr, repeat(gap: 2.5 * px, tx(".", font: mono, size: 10, lh: 20, fill: ink.border-strong)))
#let content-row((n, title, how)) = block(spacing: 0pt, {
  set par(leading: 0pt)
  box(width: 30 * px, m(n, size: 10.5, fill: ink.amber-600, lh: 20))
  sf(title, size: 16, lh: 20)
  h(8 * px)
  leader
  h(8 * px)
  m(how, size: 9.5, fill: ink.secondary, lh: 20)
})

#grid(
  columns: (452 * px, 1fr),
  column-gutter: 32 * px,
  rows: (720 * px,),
  // Left: title, deck, contents, metadata.
  block(height: 100%, {
    v(16 * px)
    // Optical alignment: the serif's side bearing sets "s" 4 px in.
    move(dx: -4 * px, para(sf("sheet-kit", size: 112, lh: 104, fill: ink.paper)))
    v(4 * px)
    move(dx: -1 * px, para(sf("infographics, typeset.", size: 40, lh: 48, style: "italic", fill: ink.amber-400)))
    v(24 * px)
    block(width: 410 * px, para(ss("A concept book drawn from one real run: four spec-driven tools, one brief, 13 October 2026. Every mark on these pages is set by code from the data.", size: 15, lh: 22, fill: ink.secondary)))
    v(32 * px)
    para(tx("Contents", font: mono, size: 12, lh: 14, tracking: 0.06em, caps: true, fill: ink.amber-600) + h(1fr) + m("page · what is drawn", size: 9, fill: ink.muted, lh: 14))
    v(12 * px)
    stack(spacing: 8 * px, ..contents.map(content-row))
    v(1fr)
    stack(spacing: 4 * px, ..(
      ("ENGINE", "Typst 0.15.1 · cetz 0.5.3 · fletcher 0.5.8"),
      ("TYPE", "Newsreader · Inter · JetBrains Mono"),
      ("DATA", "The 13 Oct 2026 run · checked " + checked),
    ).map(((k, v)) => para(box(width: 76 * px, m(k, size: 9, fill: ink.muted, tr: 0.06em, lh: 13)) + m(v, size: 9.5, fill: ink.secondary, lh: 13))))
  }),
  // Right: the sunflower with its key.
  block(height: 100%, {
    v(1fr)
    align(center, sunflower)
    v(1fr)
    // Key: one swatch per band, fastest first.
    grid(columns: (1fr,) * 4, column-gutter: 12 * px,
      ..order.map(r => stack(spacing: 8 * px,
        box(width: 100%, height: 4 * px, radius: 2 * px, fill: shade.at(r.name)),
        para(m(upper(r.name), size: 9, fill: ink.paper, tr: 0.05em, lh: 12)),
        para(m(str(r.time) + " s · $" + str(r.cost), size: 9.5, fill: ink.secondary, lh: 12)),
      )),
    )
    v(16 * px)
    para(m("FIG. 1 — 1,007 dots, one per second of the run, on a golden-angle spiral. The fastest run is the core; each slower one rings it.", size: 9, fill: ink.muted, lh: 13))
  }),
)
