#import "/kit/typst/sheet.typ": *
#import "/data.typ": *

#show: sheet.with(section: "The run, drawn")

// Data: the 13 Oct 2026 run (page 5). Order: dearest to cheapest.
// The run from the shared data, each tool with its colour.
#let run = run.map(r => r + (ink: tool-ink(ink).at(r.name)))






// --- The glyph: one run of one tool -------------------------------------------
// core   area = cost; filled amber if the tool asked before coding
// arc    sweep = time (a full turn = 500 s)
// rays   one per prompt
// ring   13 dots = the acceptance checks; a hollow dot is a miss
#let glyph(t, s: 1, key: false) = {
  import cetz.draw: *
  let rc = (9 + 21 * calc.sqrt(t.cost / 2.84)) * s
  let ra = 40 * s
  let rr = (48 * s, 55 * s)
  let rd = 63 * s
  // track + time arc
  circle((0, 0), radius: ra, stroke: (paint: ink.soft, thickness: 6 * s * px), fill: none)
  arc((0, 0), start: 90deg, delta: -t.time / 500 * 360deg, radius: ra, anchor: "origin", mode: "OPEN",
    stroke: (paint: t.ink, thickness: 6 * s * px, cap: "round"))
  // rays
  for i in range(t.prompts) {
    let a = 90deg - i * 360deg / t.prompts
    line((rr.at(0) * calc.cos(a), rr.at(0) * calc.sin(a)), (rr.at(1) * calc.cos(a), rr.at(1) * calc.sin(a)),
      stroke: (paint: ink.secondary, thickness: 1.6 * s * px, cap: "round"))
  }
  // checks ring
  for i in range(13) {
    let a = 90deg - i * 360deg / 13
    let p = (rd * calc.cos(a), rd * calc.sin(a))
    if i < t.checks { circle(p, radius: 3.1 * s, fill: ink.paper, stroke: none) }
    else { circle(p, radius: 3.1 * s, fill: ink.card, stroke: 1.4 * s * px + ink.amber-400) }
  }
  // core
  if t.asked {
    circle((0, 0), radius: rc + 6 * s, fill: gradient.radial(t.ink.transparentize(60%), t.ink.transparentize(100%)), stroke: none)
    circle((0, 0), radius: rc, fill: t.ink, stroke: none)
  } else {
    circle((0, 0), radius: rc, fill: ink.card, stroke: 1.6 * s * px + t.ink)
  }
}

#let glyph-cell(t) = {
  canvas({
    import cetz.draw: *
    glyph(t)
    content((0, -84), anchor: "north", sf(t.name, size: 16))
    content((0, -104), anchor: "north", m("$" + str(t.cost) + " · " + str(t.time) + " s", size: 9.5, fill: ink.paper))
    content((0, -118), anchor: "north", m(str(t.prompts) + " prompts · " + str(t.checks) + "/13", size: 9.5))
  })
}

// "How to read": a small glyph with numbered layers, and the legend beside it.
#let key-glyph = canvas({
  import cetz.draw: *
  let s = 0.62
  glyph((cost: 2.16, time: 300, prompts: 6, checks: 12, asked: true, ink: ink.amber-500), s: s)
  let mark(p, n) = content(p, badge(n))
  mark((0, 0), 1)
  mark((-40 * s * 0.72, 40 * s * 0.72), 2)
  mark((51.5 * s, -2), 3)
  mark((-63 * s * 0.5, -63 * s * 0.87), 4)
})
#let legend = (
  ("core", "Area is the cost. Filled: asked before coding."),
  ("arc", "Time to a passing build. A full turn is 500 s."),
  ("rays", "One ray per prompt you had to send."),
  ("ring", "The 13 acceptance checks. Hollow is a miss."),
)
#let key = grid(
  columns: (96 * px, 1fr, 1fr, 1fr, 1fr),
  column-gutter: 14 * px,
  align: (left + horizon, left + top, left + top, left + top, left + top),
  key-glyph,
  ..legend.enumerate().map(((i, (t, b))) => stack(spacing: 6 * px,
    stack(dir: ltr, spacing: 6 * px, badge(i + 1), box(height: 15 * px, align(horizon, m(upper(t), size: 9, fill: ink.amber-400, tr: 0.06em)))),
    para(tx(b, size: 10.5, lh: 14, fill: ink.secondary)),
  )),
)

// --- Orbits: how close each tool's gate sits to the code --------------------
#let orbits = canvas({
  import cetz.draw: *
  let rings = (("disk", 38), ("IDE", 70), ("prompt", 102), ("nowhere", 134))
  for (i, (name, r)) in rings.enumerate() {
    circle((0, 0), radius: r, fill: none, stroke: (paint: if i == 0 { ink.amber-700 } else { ink.border }, thickness: 1 * px, dash: if name == "nowhere" { "dashed" } else { none }))
    content((0, r + 4), anchor: "south", box(fill: ink.card, inset: (x: 3 * px), m(upper(name), size: 8.5, fill: if i == 0 { ink.amber-400 } else { ink.muted }, tr: 0.06em)))
  }
  circle((0, 0), radius: 14, fill: gradient.radial(ink.amber-500.transparentize(30%), ink.amber-500.transparentize(100%)), stroke: none)
  content((0, 0), m("CODE", size: 8, fill: ink.paper, weight: 700))
  let place-tool(name, r, deg, label-side: "west", hi: false) = {
    let p = (r * calc.cos(deg * 1deg), r * calc.sin(deg * 1deg))
    if hi { circle(p, radius: 13, fill: gradient.radial(ink.amber-500.transparentize(40%), ink.amber-500.transparentize(100%)), stroke: none) }
    circle(p, radius: if hi { 6.5 } else { 5 }, fill: if hi { ink.amber-500 } else { ink.secondary }, stroke: 2 * px + ink.card)
    let off = if label-side == "west" { 9 } else { -9 }
    content((p.at(0) + off, p.at(1)), anchor: label-side, box(fill: ink.card, inset: (x: 3 * px, y: 1 * px), m(name, size: 10, fill: if hi { ink.paper } else { ink.secondary }, weight: if hi { 700 } else { 400 })))
  }
  // Long names sit near the top and bottom of a ring, where there is room.
  place-tool("sdd-kit", 38, -40, hi: true)
  place-tool("Kiro", 70, 180, label-side: "east")
  place-tool("BMAD", 102, 55)
  place-tool("OpenSpec", 102, 125, label-side: "east")
  place-tool("Spec Kit", 102, 222, label-side: "east")
  place-tool("Superpowers", 102, 302)
  place-tool("AGENTS.md", 134, 262)
})

// --- Units: 1,007 seconds, one dot each ------------------------------------
#let seconds = canvas({
  import cetz.draw: *
  let (pitch, rows, gap) = (6.4, 12, 32)
  let x = 0
  for t in run {
    let cols = calc.ceil(t.time / rows)
    content((x, rows * pitch + 18), anchor: "south-west", sf(t.name, size: 14))
    content((x, rows * pitch + 4), anchor: "south-west", m(str(t.time) + " s", size: 10, fill: ink.secondary))
    for i in range(t.time) {
      let c = calc.floor(i / rows)
      let r = calc.rem(i, rows)
      circle((x + c * pitch + pitch / 2, (rows - r) * pitch - pitch / 2), radius: 2.15, fill: t.ink, stroke: none)
    }
    x = x + cols * pitch + gap
  }
  // Annotation on the fast one.
  let sx = x - gap
  line((sx + 8, rows * pitch / 2), (sx + 30, rows * pitch / 2), stroke: 1 * px + ink.border-strong)
  content((sx + 36, rows * pitch / 2 + 8), anchor: "west", m("FASTEST, AND IT SKIPPED A STEP", size: 9, fill: ink.amber-400, tr: 0.06em))
  content((sx + 36, rows * pitch / 2 - 8), anchor: "west", m("brainstorming never ran: no question asked", size: 9.5, fill: ink.secondary))
})

// --- Page ---------------------------------------------------------------------
#headline("Same brief, four tools: the run, drawn.", note: "8.6× apart on cost · 11.8× on time · 4 of 4 kept the gate in the prompt")
#v(16 * px)

#grid(
  columns: (612 * px, 1fr),
  rows: (452 * px, 182 * px),
  column-gutter: 16 * px,
  row-gutter: 16 * px,
  tile({
    lbl("Four tools, one brief")
    v(4 * px)
    para(sf("Each glyph is one run.", size: 18))
    v(14 * px)
    grid(columns: (1fr,) * 4, align: center, ..run.map(glyph-cell))
    v(1fr)
    block(width: 100%, fill: ink.elevated, radius: 12 * px, inset: (x: 14 * px, top: 10 * px, bottom: 12 * px), stack(spacing: 8 * px,
      m("HOW TO READ A GLYPH", size: 9, fill: ink.muted, tr: 0.06em),
      key,
    ))
  }),
  tile({
    lbl("Where the gate lives")
    v(4 * px)
    para(sf("How close it sits to the code.", size: 18))
    v(1fr)
    align(center, orbits)
    v(1fr)
    para(m("The farther out, the easier it is to skip. Only one ring is a file the agent can't argue with.", size: 9.5, fill: ink.secondary))
  }),
  grid.cell(colspan: 2, tile({
    grid(columns: (1fr, auto), align: (left + bottom, right + bottom),
      lbl("1,007 seconds to a passing build"),
      m("one dot = one second", size: 9.5, fill: ink.muted),
    )
    v(12 * px)
    seconds
  })),
)
