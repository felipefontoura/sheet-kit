#import "/kit/typst/sheet.typ": *
#import "/data.typ": *

#show: sheet.with(section: "Shapes")

// Layout (px): content 960 × 720, panels inset 20, gutters 16.
#let (gut, ins) = (16, 20)
#let (left-w, right-w) = (464, 480)
#let (row1, row2) = (420, 232)
#let (guide, data-line, emph) = (strokes.guide, strokes.data, strokes.emph)

// The five axes, clockwise from the top. Each value is divided by the
// largest of the four tools on that axis.
#let axes = (
  (key: "cost", label: "COST", fmt: v => "$" + str(v)),
  (key: "time", label: "TIME", fmt: v => str(v) + " s"),
  (key: "prompts", label: "PROMPTS", fmt: v => str(v)),
  (key: "spec-lines", label: "SPEC LINES", fmt: v => str(v)),
  (key: "tokens", label: "TOKENS IN", fmt: v => { let t = str(calc.round(v, digits: 2)); if t.split(".").last().len() < 2 { t + "0" } else { t } + "M" }),
)
#let maxes = axes.map(a => calc.max(..run.map(r => r.at(a.key))))
#let ink-of = tool-ink(ink)
#let angle(i) = 90deg - i * 72deg
#let pt(i, r) = (r * calc.cos(angle(i)), r * calc.sin(angle(i)))
#let shares(t) = axes.enumerate().map(((i, a)) => t.at(a.key) / maxes.at(i))

// Label anchor that keeps text off its axis end.
#let anchor-for(i) = ("south", "west", "north-west", "north-east", "east").at(i)

// Panel heads with a 1.25 line height, the note on the title's baseline.
#let head-row(kicker, title, note: none, size: 16) = panel-head(kicker, title, size: size, lh: size * 1.25, note: note)

// Radar scaffold: rings at 25/50/75/100 %, spokes.
#let scaffold(R) = {
  import cetz.draw: *
  for q in (0.25, 0.5, 0.75, 1) {
    line(..range(5).map(i => pt(i, R * q)), close: true, fill: none, stroke: (paint: if q == 1 { ink.border-strong } else { ink.soft }, thickness: guide))
  }
  for i in range(5) { line((0, 0), pt(i, R), stroke: guide + ink.soft) }
}

#let shape(t, R, alpha: 72%) = {
  import cetz.draw: *
  let c = ink-of.at(t.name)
  let ps = shares(t).enumerate().map(((i, s)) => pt(i, R * s))
  line(..ps, close: true, fill: c.transparentize(alpha), stroke: data-line + c)
  for p in ps { circle(p, radius: 2.5, fill: c, stroke: none) }
}

// --- Hero: all four shapes on one radar ---------------------------------------
#let hero-w = left-w - 2 * ins // 424
#let hero-h = 252
#let hero = canvas({
  import cetz.draw: *
  frame(hero-w, hero-h)
  let R = 96
  let (cx, cy) = (hero-w / 2, 126)
  group({
    translate((cx, cy))
    scaffold(R)
    for t in run { shape(t, R, alpha: if t.name == "Spec Kit" { 80% } else { 66% }) }
    for (i, a) in axes.enumerate() {
      let (x, y) = pt(i, R + 10)
      content((x, y), anchor: anchor-for(i), box(inset: 2 * px, stack(spacing: 2 * px,
        m(a.label, size: 9, fill: ink.amber-400, tr: 0.06em, lh: 12),
        m("max " + (a.fmt)(maxes.at(i)), size: 9, fill: ink.secondary, lh: 12),
      )))
    }
    // Callouts, numbered; the notes under the radar explain them.
    // 1 sits beside Spec Kit's top vertex; 2 points at Superpowers' shape.
    let (tx0, ty0) = pt(0, R)
    content((tx0 + 52, ty0 + 16), anchor: "center", badge(1))
    // Badge 2 sits in the open band above the outer edge, its leader rising
    // to Superpowers' lowest vertex.
    let sp = run.find(t => t.name == "Superpowers")
    let (sx, sy) = pt(2, R * shares(sp).at(2))
    line((0, -52), (sx - 2, sy - 4), stroke: guide + ink.paper)
    content((0, -60), anchor: "center", badge(2))
  })
})

// --- Small multiples: identical radars, one per tool ---------------------------
#let cell-w = (right-w - 2 * ins - gut) / 2 // 212
#let cell-h = 150
#let multiple(t) = canvas({
  import cetz.draw: *
  frame(cell-w, cell-h)
  let R = 44
  let (cx, cy) = (cell-w / 2 + 14, 66)
  content((0, cell-h), anchor: "north-west", sf(t.name, size: 15, lh: 18))
  content((0, cell-h - 22), anchor: "north-west", m(str(t.checks) + "/13 checks", size: 9, fill: ink.secondary, lh: 12))
  group({
    translate((cx, cy))
    scaffold(R)
    shape(t, R, alpha: 60%)
    for (i, a) in axes.enumerate() {
      let (x, y) = pt(i, R + 8)
      content((x, y), anchor: anchor-for(i), m((a.fmt)(t.at(a.key)), size: 9, fill: ink.paper, lh: 12))
    }
  })
})

// --- Dumbbell: prompts sent → checks passed (same 0–13 count axis) ----------------
#let db-w = left-w - 2 * ins
#let dumbbell = canvas({
  import cetz.draw: *
  let (x0, pitch, top) = (96, 26, 16 + 4 * 26)
  frame(db-w, top + 4)
  let w = db-w - x0 - 16
  let X(v) = x0 + v / 13 * w
  for v in (0, 2, 4, 6, 8, 10, 12, 13) {
    line((X(v), 16), (X(v), top), stroke: guide + ink.soft)
    content((X(v), 12), anchor: "north", m(str(v), size: 8.5, fill: ink.muted, lh: 12))
  }
  for (i, t) in run.enumerate() {
    let y = top - (i + 0.5) * pitch
    content((x0 - 12, y), anchor: "east", m(t.name, size: 10, fill: ink.paper, lh: 12))
    line((X(t.prompts), y), (X(t.checks), y), stroke: data-line + ink-of.at(t.name))
    circle((X(t.prompts), y), radius: 5, fill: ink.card, stroke: data-line + ink-of.at(t.name))
    circle((X(t.checks), y), radius: 5, fill: ink-of.at(t.name), stroke: none)
  }
})

// --- Decision quadrant ----------------------------------------------------------------
#let quote-cell(t, hi: false) = block(width: 100%, height: 100%, fill: if hi { ink.amber-500.transparentize(86%) } else { ink.elevated }, stroke: if hi { guide + ink.amber-700 } else { none }, radius: 10 * px, inset: (x: 12 * px, y: 6 * px), align(horizon, {
  para(sf(t.name, size: 14, lh: 16))
  v(4 * px)
  para(ss("“" + t.decision + "”", size: 10, lh: 12, fill: ink.secondary, style: "italic"))
}))
#let find(n) = run.find(t => t.name == n)
#let quadrant = grid(
  columns: (48 * px, 1fr, 1fr),
  rows: (12 * px, 1fr, 1fr),
  column-gutter: 8 * px,
  row-gutter: 8 * px,
  [], align(center, m("DID NOT ASK", size: 8.5, fill: ink.muted, tr: 0.06em, lh: 12)), align(center, m("ASKED FIRST", size: 8.5, fill: ink.amber-400, tr: 0.06em, lh: 12)),
  align(left + horizon, m("RIGHT", size: 8.5, fill: ink.amber-400, tr: 0.06em, lh: 12)), quote-cell(find("Superpowers")), quote-cell(find("BMAD"), hi: true),
  align(left + horizon, m("WRONG", size: 8.5, fill: ink.muted, tr: 0.06em, lh: 12)), quote-cell(find("OpenSpec")), quote-cell(find("Spec Kit")),
)

// --- Page -------------------------------------------------------------------------------
#para(sf("Shapes of a run: same brief, four footprints.", size: 32, lh: 36) + h(1fr) + m("The 13 Oct run · n = 1 per tool", size: 10, fill: ink.secondary, lh: 12))
#v(16 * px)
#let swatch(n) = box(width: 9 * px, height: 9 * px, radius: 2 * px, fill: ink-of.at(n)) + h(6 * px) + ss(n, size: 11, fill: ink.secondary, lh: 16) + h(16 * px)
#grid(
  columns: (left-w * px, right-w * px),
  rows: (row1 * px, row2 * px),
  column-gutter: gut * px,
  row-gutter: gut * px,
  tile(inset: ins, {
    head-row("Radar · overlay", "Four footprints on one scale.", size: 18)
    v(8 * px)
    para(run.map(t => swatch(t.name)).join())
    v(12 * px)
    hero
    v(1fr)
    grid(columns: (auto, 1fr, auto, 1fr), column-gutter: 8 * px, align: left + top,
      badge(1), para(ss("Spec Kit is the largest on all five axes: its shape is the whole pentagon.", size: 11, fill: ink.secondary, lh: 15)),
      badge(2), para(ss("Superpowers never passes 20% of the scale, on any axis.", size: 11, fill: ink.secondary, lh: 15)),
    )
  }),
  tile(inset: ins, {
    head-row("Radar · small multiples", "Each tool alone, real values at the tips.", note: "same axes, same scale")
    v(12 * px)
    grid(columns: (cell-w * px, cell-w * px), rows: (cell-h * px, cell-h * px), column-gutter: gut * px, row-gutter: gut * px,
      ..run.map(multiple))
    v(1fr)
    source("Scale: each value ÷ the largest of the four. All five maxima are Spec Kit's.")
  }),
  tile(inset: ins, {
    head-row("Dumbbell", "Prompts in, checks out.", note: ss("○", size: 10, fill: ink.muted, lh: 12) + m(" prompts sent · ", size: 9, fill: ink.muted, lh: 12) + ss("●", size: 10, fill: ink.muted, lh: 12) + m(" checks passed", size: 9, fill: ink.muted, lh: 12))
    v(12 * px)
    dumbbell
    v(1fr)
    source("Checks are the 13-item acceptance list. More prompts bought no more checks.")
  }),
  tile(inset: ins, {
    head-row("Quadrant", "Asking first did not make it right.", note: "the key: required or optional?")
    v(12 * px)
    block(height: 1fr, quadrant)
  }),
)
