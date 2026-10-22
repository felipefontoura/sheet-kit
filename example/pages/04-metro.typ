#import "/kit/typst/sheet.typ": *
#import "/data.typ": *

#show: sheet.with(section: "Command atlas")

// --- Geometry (map px, origin bottom-left, y up) -----------------------------
#let MW = 920
#let MH = 522
#let SLOT = 16 // exact offset between parallel lines
#let LW = 6 // every line, every segment
#let hub-x(k) = 190 + k * 112
#let gate-x = 582
#let yu = 300 // trunk centre, upper level (Intent → Design)
#let yl = 260 // trunk centre, lower level (Tasks → Ship)
#let xa = 450 // where the trunk starts its 45° drop
#let drop = yu - yl
#let R = 44 // centre radius of the trunk bends; offsets add or subtract
#let RB = 16 // radius of every branch bend
#let tan22 = calc.tan(22.5deg)

// Lane order top to bottom. Passing lines always sit outside a hub's capsule.
#let order = ("Superpowers", "Kiro", "sdd-kit", "Spec Kit", "BMAD", "OpenSpec")
#let off(name) = (2.5 - order.position(n => n == name)) * SLOT

#let lines = (
  "Superpowers": (paint: ink.amber-300, kind: "solid"),
  "Kiro": (paint: ink.border-strong, kind: "dashed"),
  "sdd-kit": (paint: ink.amber-500, kind: "solid"),
  "Spec Kit": (paint: ink.amber-700, kind: "solid"),
  "BMAD": (paint: ink.secondary, kind: "double"),
  "OpenSpec": (paint: ink.paper, kind: "solid"),
)

// Interchanges: the command each line calls there (cheatsheet pages 2 to 4),
// keys in lane order so a board lists them as they sit in the capsule.
#let hubs = (
  (name: "Intent", side: "above", stops: ("Superpowers": "brainstorming", "sdd-kit": "/sdd-kit:steering", "Spec Kit": "/speckit-constitution", "BMAD": "/bmad-help", "OpenSpec": "/opsx:explore")),
  (name: "Spec", side: "below", stops: ("Kiro": "requirements.md", "sdd-kit": "/sdd-kit:prd", "Spec Kit": "/speckit-specify", "BMAD": "/bmad-prd", "OpenSpec": "/opsx:propose")),
  (name: "Design", side: "above", stops: ("Kiro": "design.md", "sdd-kit": "/sdd-kit:spec", "Spec Kit": "/speckit-plan", "BMAD": "/bmad-architecture")),
  (name: "Tasks", side: "below", stops: ("Superpowers": "writing-plans", "Kiro": "tasks.md", "sdd-kit": "/sdd-kit:tasks", "Spec Kit": "/speckit-tasks")),
  (name: "Build", side: "above", stops: ("Superpowers": "subagent-driven-development", "Kiro": "run the tasks", "sdd-kit": "/sdd-kit:exec", "Spec Kit": "/speckit-implement", "BMAD": "/bmad-build (story)", "OpenSpec": "/opsx:apply")),
  (name: "Review", side: "below", stops: ("Superpowers": "requesting-code-review", "sdd-kit": "/sdd-kit:review", "Spec Kit": "/speckit-converge")),
  (name: "Ship", side: "above", stops: ("Superpowers": "finishing-a-development-branch", "BMAD": "/bmad-retrospective", "OpenSpec": "/opsx:archive")),
)

// Where each line starts and ends along the trunk, and its own stations.
// `from: "left"` lines enter through a fan of branches at the left edge.
#let routes = (
  "Superpowers": (from: "left", end: 880, stations: ((x: 358, label: "using-git-worktrees"), (x: 694, label: "test-driven-development"))),
  "Kiro": (from: 250, end: 656, stations: ()),
  "sdd-kit": (from: "left", end: 768, stations: ((x: 120, label: "/sdd-kit:init", branch: true),)),
  "Spec Kit": (from: "left", end: 768, stations: ()),
  "BMAD": (from: "left", end: 880, stations: ((x: 246, label: "/bmad-build · quick path"),)),
  "OpenSpec": (from: "left", end: 880, stations: ((x: 358, label: "/opsx:update"), (x: 694, label: "/opsx:sync"))),
)

// Trunk centre y at x, and a line's y at x (offset d).
#let trunk-y(x, d) = {
  let c1 = xa + d * (calc.sqrt(2) - 1)
  let c2 = xa + drop + d * (calc.sqrt(2) - 1)
  if x <= c1 { yu + d } else if x >= c2 { yl + d } else { yu + d * calc.sqrt(2) - (x - xa) }
}

// Polyline of a line along the trunk between x0 and x1, with corner radii.
#let trunk-pts(d, x0, x1) = {
  let c1 = xa + d * (calc.sqrt(2) - 1)
  let c2 = xa + drop + d * (calc.sqrt(2) - 1)
  let pts = ((x0, trunk-y(x0, d)),)
  let rad = (0,)
  if x0 < c1 and x1 > c1 { pts.push((c1, yu + d)); rad.push(R + d) }
  if x0 < c2 and x1 > c2 { pts.push((c2, yl + d)); rad.push(R - d) }
  pts.push((x1, trunk-y(x1, d)))
  rad.push(0)
  (pts, rad)
}

// Fan branch at the left: terminal y and the bend into the trunk.
#let fan = 20
#let x-term = 90
#let TAG = 80 // every line tag, left edge on the map edge
#let branch(name) = {
  let d = off(name)
  let ys = yu + d
  let yt = ys + (2.5 - order.position(n => n == name)) * fan
  let x-join = hub-x(0) - 10
  let x-bend = x-join - calc.abs(yt - ys)
  ((x-term, yt), (x-bend, yt), (x-join, ys))
}

// Full point list and corner radii for a line.
#let path-of(name) = {
  let r = routes.at(name)
  let d = off(name)
  if r.from == "left" {
    let b = branch(name)
    let (tp, tr) = trunk-pts(d, b.at(2).at(0), r.end)
    let pts = (b.at(0), b.at(1)) + tp
    let rad = (0, RB) + tr
    // The join point is a straight continuation; give it the branch radius.
    rad.at(2) = RB
    (pts, rad)
  } else {
    trunk-pts(d, r.from, r.end)
  }
}

// Rounded polyline: each corner cut back by r·tan(θ/2) and joined with a
// quadratic Bézier whose control point is the corner (close to a circle arc).
#let rounded(pts, rad, st) = {
  import cetz.draw: *
  // Drop collinear points so a radius only lands on a real corner.
  let p = (pts.at(0),)
  let rr = (rad.at(0),)
  for i in range(1, pts.len() - 1) {
    let (ax, ay) = p.last()
    let (bx, by) = pts.at(i)
    let (cx, cy) = pts.at(i + 1)
    let cross = (bx - ax) * (cy - by) - (by - ay) * (cx - bx)
    if calc.abs(cross) > 0.01 { p.push(pts.at(i)); rr.push(rad.at(i)) }
  }
  p.push(pts.last())
  rr.push(0)
  merge-path(stroke: st, fill: none, {
    let cur = p.at(0)
    for i in range(1, p.len() - 1) {
      let (ax, ay) = p.at(i - 1)
      let (vx, vy) = p.at(i)
      let (bx, by) = p.at(i + 1)
      let l1 = calc.sqrt(calc.pow(vx - ax, 2) + calc.pow(vy - ay, 2))
      let l2 = calc.sqrt(calc.pow(bx - vx, 2) + calc.pow(by - vy, 2))
      let (u1x, u1y) = ((vx - ax) / l1, (vy - ay) / l1)
      let (u2x, u2y) = ((bx - vx) / l2, (by - vy) / l2)
      let turn = calc.acos(calc.clamp(u1x * u2x + u1y * u2y, -1, 1))
      let t = calc.min(rr.at(i) * calc.tan(turn / 2), l1 / 2, l2 / 2)
      let c1 = (vx - u1x * t, vy - u1y * t)
      let c2 = (vx + u2x * t, vy + u2y * t)
      line(cur, c1)
      bezier(c1, c2, (vx, vy))
      cur = c2
    }
    line(cur, p.last())
  })
}

#let stroke-of(name, w: LW, paint: none) = {
  let s = lines.at(name)
  (paint: if paint == none { s.paint } else { paint }, thickness: w * px, cap: "butt", join: "round")
}

// Slot y of a line at hub k (all hubs share the trunk, so it is just the offset).
#let hub-y(k, name) = trunk-y(hub-x(k), off(name))
#let level(k) = if k <= 2 { yu } else { yl }

// --- Boards: one per interchange --------------------------------------------
#let dot(paint) = box(width: 7 * px, height: 7 * px, baseline: -1.5 * px, radius: 3.5 * px, fill: paint)
#let board(k, hb) = block(fill: ink.elevated, radius: 8 * px, inset: (x: 10 * px, y: 8 * px), stack(
  spacing: 8 * px,
  para(m(pad2(k + 1), size: 9, fill: ink.muted, lh: 12) + m("  " + upper(hb.name), size: 9.5, fill: ink.amber-400, weight: 700, tr: 0.08em, lh: 12)),
  stack(spacing: 4 * px, ..hb.stops.pairs().map(((name, cmd)) => para(dot(lines.at(name).paint) + h(6 * px) + m(cmd, size: 9, fill: ink.paper, lh: 12)))),
))
// Horizontal placement of each board: centred on its hub, nudged so no two
// boards on the same side overlap and none leaves the map.
#let board-shift = (0, 0, 0, -8, -66, 0, "right")

#let map = canvas({
  import cetz.draw: *
  // Fix the canvas to the map box.
  rect((0, 0), (MW, MH), stroke: none, fill: none)

  // Zone boundary: deciding ends, building starts.
  line((gate-x, 140), (gate-x, 320), stroke: (paint: ink.amber-700, thickness: 1 * px, dash: (array: (3 * px, 3 * px))))
  content((gate-x - 8, 128), anchor: "east", m("DECIDE", size: 9, fill: ink.muted, tr: 0.08em, lh: 12))
  content((gate-x + 8, 128), anchor: "west", m("BUILD", size: 9, fill: ink.muted, tr: 0.08em, lh: 12))

  // Leaders from each capsule to its board (drawn under the lines).
  for (k, hb) in hubs.enumerate() {
    let names = hb.stops.keys()
    let top = hub-y(k, names.first()) + 7
    let bot = hub-y(k, names.last()) - 7
    if hb.side == "above" { line((hub-x(k), top), (hub-x(k), 404), stroke: 1 * px + ink.border) }
    else { line((hub-x(k), bot), (hub-x(k), 116), stroke: 1 * px + ink.border) }
  }
  // Leader from Kiro's terminus to its name tag, and BMAD's quick-path label.
  line((250, yu + off("Kiro")), (250, yu + 2.5 * SLOT + LW / 2 + 12), stroke: 1 * px + ink.border)
  line((246, yu + off("BMAD")), (246, yu - 2.5 * SLOT - LW / 2 - 8), stroke: 1 * px + ink.border)

  // Lines: casing first (a halo that cuts anything underneath), then the line.
  for name in order {
    let (pts, rad) = path-of(name)
    rounded(pts, rad, stroke-of(name, w: LW + 6, paint: ink.card))
  }
  for name in order {
    let (pts, rad) = path-of(name)
    let s = lines.at(name)
    if s.kind == "dashed" {
      rounded(pts, rad, (..stroke-of(name), dash: (array: (10 * px, 6 * px))))
    } else if s.kind == "double" {
      rounded(pts, rad, stroke-of(name))
      rounded(pts, rad, stroke-of(name, w: 2, paint: ink.card))
    } else {
      rounded(pts, rad, stroke-of(name))
    }
  }

  // Termini: a bar across the line; a tag at each fan terminal.
  for name in order {
    let r = routes.at(name)
    let d = off(name)
    let ends = (r.end,)
    if r.from != "left" { ends.push(r.from) }
    for x in ends {
      let y = trunk-y(x, d)
      rect((x - 2, y - 8), (x + 2, y + 8), fill: lines.at(name).paint, stroke: none)
    }
    let s = lines.at(name)
    let tag = box(width: TAG * px, fill: s.paint, radius: 4 * px, inset: (x: 8 * px, y: 4 * px), m(name, size: 9.5, fill: if s.paint == ink.border-strong { ink.paper } else { ink.inverse }, weight: 700, lh: 12))
    if r.from == "left" {
      let (x, y) = branch(name).at(0)
      rect((x - 2, y - 8), (x + 2, y + 8), fill: s.paint, stroke: none)
      content((0, y), anchor: "west", tag)
    } else {
      content((r.from, yu + 2.5 * SLOT + LW / 2 + 12), anchor: "south", box(width: auto, fill: s.paint, radius: 4 * px, inset: (x: 8 * px, y: 4 * px), m(name, size: 9.5, fill: ink.paper, weight: 700, lh: 12)))
    }
  }

  // Intermediate stations: a paper dot in a ring of the line's colour.
  for name in order {
    let d = off(name)
    for st in routes.at(name).stations {
      let y = if st.at("branch", default: false) { branch(name).at(0).at(1) } else { trunk-y(st.x, d) }
      circle((st.x, y), radius: 5, fill: ink.paper, stroke: 2.5 * px + lines.at(name).paint)
      // Labels sit outside the bundle: above the top line or below the bottom one.
      let lv = if st.x < xa { yu } else { yl }
      let above = name == "Superpowers" or st.at("branch", default: false)
      let ly = if st.at("branch", default: false) { y + 6.25 + 6 } else if above { lv + 2.5 * SLOT + LW / 2 + 8 } else { lv - 2.5 * SLOT - LW / 2 - 8 }
      content((st.x, ly), anchor: if above { "south" } else { "north" }, m(st.label, size: 9, fill: ink.secondary, lh: 12))
    }
  }

  // Interchanges: a paper capsule over the stopping slots, a dot per line.
  for (k, hb) in hubs.enumerate() {
    let names = hb.stops.keys()
    let x = hub-x(k)
    let y0 = hub-y(k, names.first())
    let y1 = hub-y(k, names.last())
    rect((x - 8, y1 - 7), (x + 8, y0 + 7), radius: 8, fill: ink.paper, stroke: 2 * px + ink.card)
    for name in names { circle((x, hub-y(k, name)), radius: 3, fill: if lines.at(name).paint == ink.paper { ink.muted } else { lines.at(name).paint }, stroke: none) }
  }

  // The one human gate: a barrier across sdd-kit, between Tasks and Build.
  let gy = trunk-y(gate-x, off("sdd-kit"))
  circle((gate-x, gy), radius: 16, fill: gradient.radial(ink.amber-500.transparentize(55%), ink.amber-500.transparentize(100%)), stroke: none)
  rect((gate-x - 3, gy - 8), (gate-x + 3, gy + 8), radius: 1.5, fill: ink.amber-300, stroke: 1.5 * px + ink.card)
  content((gate-x + 12, 188), anchor: "north-west", block(stack(spacing: 4 * px,
    para(badge(1) + h(6 * px) + m("HUMAN GATE", size: 9.5, fill: ink.amber-400, weight: 700, tr: 0.08em, lh: 15)),
    para(m("tasks:approved", size: 9.5, fill: ink.paper, lh: 13)),
    para(m("a person edits .status", size: 9, fill: ink.secondary, lh: 12)),
  )))

  // Symbol key, in the empty corner under the Intent hub.
  let kx = 0
  let ky = 96
  content((kx, ky), anchor: "north-west", m("HOW TO READ", size: 9, fill: ink.muted, tr: 0.08em, lh: 12))
  let row(i) = ky - 24 - i * 20
  // station
  line((kx, row(0)), (kx + 24, row(0)), stroke: (paint: ink.secondary, thickness: LW * px))
  circle((kx + 12, row(0)), radius: 5, fill: ink.paper, stroke: 2.5 * px + ink.secondary)
  content((kx + 32, row(0)), anchor: "west", m("stop: one command", size: 9, fill: ink.secondary, lh: 12))
  // interchange
  rect((kx + 4, row(1) - 9), (kx + 20, row(1) + 9), radius: 8, fill: ink.paper, stroke: none)
  circle((kx + 12, row(1) - 4), radius: 3, fill: ink.amber-500, stroke: none)
  circle((kx + 12, row(1) + 4), radius: 3, fill: ink.amber-700, stroke: none)
  content((kx + 32, row(1)), anchor: "west", m("interchange: same phase", size: 9, fill: ink.secondary, lh: 12))
  // terminus
  line((kx, row(2)), (kx + 12, row(2)), stroke: (paint: ink.secondary, thickness: LW * px))
  rect((kx + 10, row(2) - 8), (kx + 14, row(2) + 8), fill: ink.secondary, stroke: none)
  content((kx + 32, row(2)), anchor: "west", m("terminus", size: 9, fill: ink.secondary, lh: 12))
  // gate
  rect((kx + 9, row(3) - 8), (kx + 15, row(3) + 8), radius: 1.5, fill: ink.amber-300, stroke: none)
  content((kx + 32, row(3)), anchor: "west", m("human gate: a file, not a prompt", size: 9, fill: ink.amber-400, lh: 12))

  // Boards.
  for (k, hb) in hubs.enumerate() {
    let s = board-shift.at(k)
    let b = board(k, hb)
    if hb.side == "above" {
      if s == "right" { content((MW, 404), anchor: "south-east", b) }
      else { content((hub-x(k) + s, 404), anchor: "south", b) }
    } else {
      content((hub-x(k) + s, 116), anchor: "north", b)
    }
  }
})

// --- Page ---------------------------------------------------------------------
#grid(
  columns: (1fr, auto),
  align: (left + bottom, right + bottom),
  {
    lbl("Command atlas")
    v(4 * px)
    para(sf("Every command, one map.", size: 30, lh: 36))
  },
  {
    para(m("6 lines · 36 stops · 7 interchanges · 1 human gate", size: 10, fill: ink.secondary, lh: 13))
    v((base-gap(serif, 30, 36) - base-gap(mono, 10, 13)) * px)
  },
)
#v(16 * px)

#block(height: 562 * px, width: 100%, tile(inset: 20, {
  // Map paper: a dot grid, a shade brighter past the gate.
  place(top + left, rect(width: gate-x * px, height: MH * px, fill: tiling(size: (16 * px, 16 * px), place(dx: 7.5 * px, dy: 7.5 * px, circle(radius: 0.9 * px, fill: ink.soft)))))
  place(top + left, dx: gate-x * px, rect(width: (MW - gate-x) * px, height: MH * px, fill: tiling(size: (16 * px, 16 * px), place(dx: 7.5 * px, dy: 7.5 * px, circle(radius: 0.9 * px, fill: ink.border)))))
  map
}))
#v(16 * px)

// Legend: line style, name, how many stops, where its gate lives.
#let gate-of(name) = tools.find(t => t.name == name).gate
#let stops-of(name) = hubs.filter(x => name in x.stops).len() + routes.at(name).stations.len()
#let sample(name) = {
  let s = lines.at(name)
  box(width: 28 * px, height: 12 * px, baseline: -1 * px, canvas({
    import cetz.draw: *
    let st = (paint: s.paint, thickness: LW * px, cap: "butt")
    if s.kind == "dashed" { line((0, 6), (28, 6), stroke: (..st, dash: (array: (10 * px, 6 * px)))) }
    else { line((0, 6), (28, 6), stroke: st) }
    if s.kind == "double" { line((0, 6), (28, 6), stroke: (paint: ink.card, thickness: 2 * px, cap: "butt")) }
  }))
}
#block(height: 72 * px, width: 100%, tile(inset: 20, grid(
  columns: (1fr,) * 6,
  column-gutter: 16 * px,
  align: left + horizon,
  ..order.map(name => grid(columns: (28 * px, 1fr), column-gutter: 8 * px, align: left + horizon,
    sample(name),
    stack(spacing: 4 * px,
      para(ss(name, size: 11, weight: 600, lh: 14)),
      para(m(str(stops-of(name)) + " stops · " + gate-of(name), size: 9, fill: if gate-of(name) == "disk" { ink.amber-400 } else { ink.secondary }, lh: 12)),
    ),
  )),
)))
