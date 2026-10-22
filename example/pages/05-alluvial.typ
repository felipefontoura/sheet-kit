#import "/kit/typst/sheet.typ": *
#import "/data.typ": *

#show: sheet.with(section: "Flows")

// Columns of the alluvial, top to bottom, so no two ribbons cross.
#let order = ("AGENTS.md", "OpenSpec", "Spec Kit", "Superpowers", "BMAD", "Kiro", "sdd-kit")
#let tool(name) = tools.find(t => t.name == name)
#let places = (
  (key: "nowhere", label: "Nowhere"),
  (key: "prompt", label: "The prompt"),
  (key: "IDE", label: "An IDE click"),
  (key: "disk", label: "A file on disk"),
)
#let verdicts = (
  (key: "no gate", label: "no gate to skip"),
  (key: "yes", label: "the agent can skip it"),
  (key: "hard", label: "hard to skip"),
)
#let count(field, key) = order.filter(n => tool(n).at(field) == key).len()

// --- Alluvial geometry (px, origin bottom-left) ------------------------------
#let AW = 920
#let FH = 328 // height of the flow region
#let U = 30 // one tool
#let x1 = 140 // tool bars
#let x2 = 376 // gate blocks
#let BLK = 168 // gate block width
#let x3 = 772 // verdict bars
#let BW = 8 // bar width

// Top offsets (px from the top of the flow region) of each node.
#let stack-nodes(sizes, gap) = {
  let out = ()
  // Centred in the flow region, so columns of different heights funnel.
  let t = (FH - sizes.sum() - gap * (sizes.len() - 1)) / 2
  for s in sizes { out.push((t, t + s)); t += s + gap }
  out
}
#let tool-nodes = stack-nodes(order.map(_ => U), 16)
#let place-nodes = stack-nodes(places.map(p => count("gate", p.key) * U), 12)
#let verdict-nodes = stack-nodes(verdicts.map(v => count("skip", v.key) * U), 40)
#let Y(t) = FH - t

// Each tool's slot inside its gate block and its verdict bar, in tool order.
#let slots = {
  let out = (:)
  let used-p = places.map(_ => 0)
  let used-v = verdicts.map(_ => 0)
  for (i, n) in order.enumerate() {
    let pi = places.position(p => p.key == tool(n).gate)
    let vi = verdicts.position(v => v.key == tool(n).skip)
    let pt = place-nodes.at(pi).at(0) + used-p.at(pi)
    let vt = verdict-nodes.at(vi).at(0) + used-v.at(vi)
    used-p.at(pi) += U
    used-v.at(vi) += U
    out.insert(n, (a: tool-nodes.at(i), b: (pt, pt + U), c: (vt, vt + U), p: pi, v: vi))
  }
  out
}

// Texture says how the gate is held: solid amber on disk, a hatch for a
// prompt (it has holes), a dot screen for an IDE click, an outline for none.
// sdd-kit's ribbon starts and ends in the amber of the bars and the block it
// joins (no seam), and dips darker in between.
#let style(name) = if name == "sdd-kit" {
  (fill: gradient.linear((ink.amber-500, 0%), (ink.amber-700, 50%), (ink.amber-500, 100%)), over: none, stroke: none)
} else if name == "AGENTS.md" {
  (fill: none, over: none, stroke: (paint: ink.muted, thickness: 1 * px, dash: (array: (3 * px, 3 * px))))
} else if name == "Kiro" {
  (fill: ink.secondary.transparentize(88%), over: screen(), stroke: none)
} else {
  (fill: ink.secondary.transparentize(88%), over: hatch(), stroke: none)
}

#let alluvial = canvas({
  import cetz.draw: *
  rect((0, 0), (AW, FH + 32), stroke: none, fill: none)
  // Column heads.
  let head-y = FH + 32
  content((x1 - 12, head-y), anchor: "north-east", m("TOOL", size: 9, fill: ink.muted, tr: 0.08em, lh: 12))
  content((x2 + BLK / 2, head-y), anchor: "north", m("WHERE THE GATE LIVES", size: 9, fill: ink.muted, tr: 0.08em, lh: 12))
  content((x3 + BW + 12, head-y), anchor: "north-west", m("CAN IT BE SKIPPED?", size: 9, fill: ink.muted, tr: 0.08em, lh: 12))

  // Ribbons.
  for n in order {
    let s = slots.at(n)
    let st = style(n)
    // Kit ribbons tuck under the bars and blocks they join (no seams), so
    // they are drawn first.
    for seg in ((x1 + BW, s.a, x2, s.b), (x2 + BLK, s.b, x3, s.c)) {
      let (xa, ra, xb, rb) = seg
      let ys = (Y(ra.at(0)), Y(ra.at(1)), Y(rb.at(0)), Y(rb.at(1)))
      ribbon(xa, ys.at(0), ys.at(1), xb, ys.at(2), ys.at(3), paint: st.fill, edge: st.stroke)
      if st.over != none { ribbon(xa, ys.at(0), ys.at(1), xb, ys.at(2), ys.at(3), paint: st.over) }
    }
  }

  // Tool bars and labels.
  for (i, n) in order.enumerate() {
    let (ta, tb) = tool-nodes.at(i)
    let paint = if n == "sdd-kit" { ink.amber-500 } else if n == "AGENTS.md" { ink.muted } else { ink.secondary }
    rect((x1, Y(tb)), (x1 + BW, Y(ta)), fill: paint, stroke: none)
    let t = tool(n)
    let meta = if t.version == none { "no install" } else if n == "Kiro" { "IDE 1.4.10" } else { "v" + t.version }
    content((x1 - 12, Y((ta + tb) / 2) + 7), anchor: "east", ss(n, size: 12, weight: 600, fill: if n == "sdd-kit" { ink.amber-400 } else { ink.paper }, lh: 14))
    content((x1 - 12, Y((ta + tb) / 2) - 8), anchor: "east", m(meta, size: 9, fill: ink.secondary, lh: 12))
  }

  // Gate blocks.
  for (i, p) in places.enumerate() {
    let (ta, tb) = place-nodes.at(i)
    let n = count("gate", p.key)
    let disk = p.key == "disk"
    // Square corners: ribbons meet the block flush, like the end bars.
    rect((x2, Y(tb)), (x2 + BLK, Y(ta)),
      fill: if disk { ink.amber-500 } else if p.key == "nowhere" { ink.card } else { ink.soft },
      stroke: if p.key == "nowhere" { (paint: ink.muted, thickness: 1 * px, dash: (array: (3 * px, 3 * px))) } else { none })
    let fg = if disk { ink.inverse } else { ink.paper }
    if tb - ta > U {
      // The tall block: label, the count, and what it means.
      content((x2 + 12, Y(ta) - 12), anchor: "north-west", m(upper(p.label), size: 9.5, fill: fg, weight: 700, tr: 0.06em, lh: 12))
      content((x2 + 12, Y(tb) + 12), anchor: "south-west", stack(spacing: 4 * px,
        para(sf("4 of 7", size: 32, lh: 32, fill: ink.paper)),
        para(m("all four tools we ran", size: 9, fill: ink.secondary, lh: 12)),
      ))
    } else {
      content((x2 + 12, Y((ta + tb) / 2)), anchor: "west", m(upper(p.label), size: 9.5, fill: fg, weight: 700, tr: 0.06em, lh: 12))
      content((x2 + BLK - 12, Y((ta + tb) / 2)), anchor: "east", m(str(n), size: 9.5, fill: fg, weight: 700, lh: 12))
    }
  }

  // Verdict bars and labels.
  for (i, v) in verdicts.enumerate() {
    let (ta, tb) = verdict-nodes.at(i)
    let paint = if v.key == "hard" { ink.amber-500 } else if v.key == "no gate" { ink.muted } else { ink.secondary }
    rect((x3, Y(tb)), (x3 + BW, Y(ta)), fill: paint, stroke: none)
    let mid = Y((ta + tb) / 2)
    content((x3 + BW + 12, mid + 8), anchor: "west", sf(str(count("skip", v.key)), size: 24, lh: 24, fill: if v.key == "hard" { ink.amber-400 } else { ink.paper }))
    content((x3 + BW + 12, mid - 12), anchor: "west", m(v.label, size: 9.5, fill: if v.key == "hard" { ink.amber-400 } else { ink.secondary }, lh: 12))
  }
})

// --- Strips: where in each workflow the approval is asked -------------------
// Gate after step i (0-based) of each workflow, and how it is held.
// Facts: cheatsheet pages 2 to 4 (gate texts) and the .status tokens (book 3.5).
#let asks = (
  "OpenSpec": ((2, "prompt"),), // update waits for your OK, before apply
  "Spec Kit": ((3, "prompt"),), // a script checks plan.md and tasks.md exist before implement
  "Superpowers": ((0, "prompt"),), // brainstorming's HARD-GATE
  "BMAD": ((1, "prompt"),), // the approval menu inside /bmad-build
  "Kiro": ((0, "IDE"), (1, "IDE"), (2, "IDE")), // a click between phases
  "sdd-kit": ((2, "disk"), (3, "disk"), (4, "disk")), // requirements:, design:, tasks:approved
)
// Hollow markers are filled with the tile's colour: the connector runs behind
// them and stops at their edge instead of showing through.
#let marker(kind) = box(width: 12 * px, height: 18 * px, align(center + horizon, {
  if kind == "disk" { rotate(45deg, rect(width: 7.5 * px, height: 7.5 * px, fill: ink.amber-500, stroke: none)) }
  else if kind == "IDE" { rect(width: 7.5 * px, height: 7.5 * px, fill: ink.card, stroke: 1.5 * px + ink.paper) }
  else { rotate(45deg, rect(width: 7 * px, height: 7 * px, fill: ink.card, stroke: 1.5 * px + ink.secondary)) }
}))
#let gap(w) = box(width: w * px, height: 18 * px)
#let pill(step, hi: false) = box(height: 18 * px, fill: ink.soft, radius: 4 * px, inset: (x: 6 * px), align(horizon, m(step, size: 9, fill: ink.paper, lh: 12)))
#let strip(name) = {
  if name == "AGENTS.md" { return box(height: 18 * px, align(horizon, m("memory only: AGENTS.md, conventions.md, decisions.md", size: 9, fill: ink.muted, lh: 12))) }
  let steps = workflows.at(name)
  let gates = asks.at(name)
  let parts = ()
  for (i, step) in steps.enumerate() {
    parts.push(pill(step))
    if i < steps.len() - 1 {
      let g = gates.find(x => x.at(0) == i)
      if g == none { parts.push(gap(16)) } else { parts.push(gap(4)); parts.push(marker(g.at(1))); parts.push(gap(4)) }
    }
  }
  // One connector under the whole row (kit `connected`): it reads unbroken.
  connected(parts)
}
#let verdict(name) = {
  let k = tool(name).skip
  if k == "hard" { m("hard to skip", size: 9, fill: ink.amber-400, lh: 12) }
  else if k == "no gate" { m("no gate", size: 9, fill: ink.muted, lh: 12) }
  else { m("skippable", size: 9, fill: ink.secondary, lh: 12) }
}
#let key-item(kind, label) = stack(dir: ltr, spacing: 4 * px, marker(kind), box(height: 18 * px, align(horizon, m(label, size: 9, fill: ink.secondary, lh: 12))))

// --- Page ---------------------------------------------------------------------
#grid(
  columns: (1fr, auto),
  align: (left + bottom, right + bottom),
  {
    lbl("Flows")
    v(4 * px)
    para(sf("Where the gate lives, as flows.", size: 30, lh: 36))
  },
  {
    para(m("7 tools · 4 places a gate can live · 1 on disk", size: 10, fill: ink.secondary, lh: 13))
    v((base-gap(serif, 30, 36) - base-gap(mono, 10, 13)) * px)
  },
)
#v(16 * px)

#block(height: 400 * px, width: 100%, tile(inset: 20, alluvial))
#v(16 * px)
#block(height: 234 * px, width: 100%, tile(inset: 20, {
  grid(columns: (1fr, auto), align: (left + horizon, right + horizon),
    lbl("Where in the workflow it asks"),
    move(dy: (base-gap(mono, 9, 12) + 3 - base-gap(mono, 12, 14) - 2) * px, stack(dir: ltr, spacing: 16 * px, key-item("prompt", "asked in the prompt"), key-item("IDE", "a click in the IDE"), key-item("disk", "a token on disk"))),
  )
  v(12 * px)
  grid(
    columns: (120 * px, 1fr, auto),
    rows: (24 * px,) * 7,
    align: (left + horizon, left + horizon, right + horizon),
    ..order.map(n => (
      move(dy: -(1 - base-gap(sans, 11, 14) + base-gap(mono, 9, 12)) * px, ss(n, size: 11, weight: 600, fill: if n == "sdd-kit" { ink.amber-400 } else { ink.paper }, lh: 14)),
      strip(n),
      verdict(n),
    )).flatten(),
  )
}))
