#import "/kit/typst/sheet.typ": *
#import "/data.typ": *

#show: sheet.with(section: "The gate")

// Page grid (px): content 960 × 720 under the header. Title block 64, gap 16,
// body 640: column A 400 | 16 | column B 544. B: code 368 | 16 | 256.
// Tiles: inset 20, radius 16. Strokes: 1 guide, 1.5 data, 2 emphasis.

#let G = 1 * px
#let theme = code-theme

// --- Title -------------------------------------------------------------------
#para(sf("The gate, engineered.", size: 32, lh: 36))
#v(8 * px)
#para(ss("Three pieces: a status file a human edits, four rules the agent reads, and a check that refuses to run.", size: 14, lh: 20, fill: ink.secondary))
#v(16 * px)

// Small mono caps used for diagram labels.
#let cap(body, size: 9, fill: ink.muted) = m(upper(body), size: size, fill: fill, tr: 0.06em, lh: size + 3)

// Dot-grid tiling: the blueprint ground under the state chart.
#let dots = tiling(size: (8 * px, 8 * px), place(dx: 3.5 * px, dy: 3.5 * px, circle(radius: 0.55 * px, fill: ink.soft)))
// Hatch: the hook's closed stretch.
#let hatch = hatch(paint: ink.amber-700)

// --- A · State × actor chart ------------------------------------------------
#let chart = canvas({
  import cetz.draw: *
  let (W, H) = (360, 544)
  let Y(y) = H - y
  let lanes = ((0, 56, "human"), (56, 188, ".status"), (188, 320, "agent"), (320, 360, "hook"))
  for (x0, x1, name) in lanes {
    content(((x0 + x1) / 2, Y(0)), anchor: "north", cap(name, fill: if name == "human" { ink.amber-400 } else { ink.secondary }))
  }
  for x in (56, 188, 320) { line((x, Y(20)), (x, Y(480)), stroke: 1 * px + ink.border) }

  let states = tokens.map(t => t.split(":"))
  let ny(i) = 28 + i * 96 // node top
  let node-h = 44
  let docs = ("requirements.md", "design.md", "tasks.md", "code + tests", "review.md")

  // The wall: code is refused above it, allowed below.
  let wall = 290
  line((0, Y(wall)), (360, Y(wall)), stroke: (paint: ink.amber-500, thickness: 2 * px, dash: (4 * px, 4 * px)))
  content((196, Y(wall - 4)), anchor: "south-west", cap("code allowed below", fill: ink.amber-400))

  // Status arrows; the three human writes are amber and 2 px.
  for i in range(4) {
    let human = i < 3
    let (x, y0, y1) = (122, ny(i) + node-h + 4, ny(i + 1) - 4)
    line((x, Y(y0)), (x, Y(y1)), stroke: (paint: if human { ink.amber-500 } else { ink.border-strong }, thickness: if human { 2 * px } else { 1.5 * px }),
      mark: (end: ">", fill: if human { ink.amber-500 } else { ink.border-strong }, scale: 0.55))
    if human {
      let ym = (ny(i) + node-h + ny(i + 1)) / 2
      line((40, Y(ym)), (118, Y(ym)), stroke: 2 * px + ink.amber-500)
      circle((122, Y(ym)), radius: 3, fill: ink.amber-500, stroke: none)
      // Person mark: head and shoulders on an amber disc.
      circle((28, Y(ym)), radius: 12, fill: ink.amber-500, stroke: none)
      circle((28, Y(ym - 4)), radius: 3.2, fill: ink.inverse, stroke: none)
      arc((28, Y(ym + 7)), start: 0deg, stop: 180deg, radius: 6, anchor: "origin", fill: ink.inverse, stroke: none, mode: "PIE")
      content((28, Y(ym + 16)), anchor: "north", cap("writes", fill: ink.amber-400))
    } else {
      let ym = (ny(i) + node-h + ny(i + 1)) / 2
      content((130, Y(ym)), anchor: "west", cap("exec", fill: ink.secondary))
    }
  }

  // Nodes, document chips and their connectors.
  for (i, (phase, state)) in states.enumerate() {
    let y = ny(i)
    let approved = state == "approved"
    rect((64, Y(y)), (180, Y(y + node-h)), radius: 8, fill: ink.soft, stroke: if approved { 1 * px + ink.amber-700 } else { none })
    content((122, Y(y + 13)), anchor: "center", cap(phase, size: 8.5, fill: ink.secondary))
    content((122, Y(y + 30)), anchor: "center", m(state, size: 12, lh: 15, fill: if approved { ink.amber-300 } else { ink.paper }, weight: 500))
    let cy = y + node-h / 2
    line((180, Y(cy)), (196, Y(cy)), stroke: (paint: ink.border-strong, thickness: 1 * px, dash: (2 * px, 2 * px)))
    rect((196, Y(cy - 12)), (316, Y(cy + 12)), radius: 6, fill: ink.elevated, stroke: 1 * px + ink.border)
    // File glyph: a page with a folded corner.
    let (fx, fy) = (204, cy - 6)
    line((fx, Y(fy)), (fx + 5, Y(fy)), (fx + 8, Y(fy + 3)), (fx + 8, Y(fy + 12)), (fx, Y(fy + 12)), close: true, stroke: 1 * px + ink.secondary, fill: none)
    content((220, Y(cy)), anchor: "west", m(docs.at(i), size: 9, lh: 12, fill: ink.paper))
  }

  // Hook track: hatched where code is refused, open below the wall.
  rect((328, Y(28)), (356, Y(wall - 6)), radius: 6, fill: hatch, stroke: 1 * px + ink.amber-700)
  content((342, Y((28 + wall - 6) / 2)), angle: 90deg, box(fill: ink.card, inset: (x: 4 * px, y: 2 * px), cap("refuses · exit 1", fill: ink.amber-400)))
  rect((328, Y(wall + 6)), (356, Y(456)), radius: 6, fill: ink.soft, stroke: 1 * px + ink.border-strong)
  content((342, Y((wall + 6 + 456) / 2)), angle: 90deg, cap("code passes", fill: ink.paper))

  // Legend.
  let leg = (
    (ink.amber-500, 2, "human writes the token"),
    (ink.border-strong, 1.5, "agent reads it, drafts, builds"),
  )
  for (k, (paint, w, label)) in leg.enumerate() {
    let y = 500 + k * 16
    line((0, Y(y)), (24, Y(y)), stroke: (paint: paint, thickness: w * px))
    content((32, Y(y)), anchor: "west", m(label, size: 9.5, lh: 12))
  }
  rect((0, Y(526)), (24, Y(538)), radius: 2, fill: hatch, stroke: 1 * px + ink.amber-700)
  content((32, Y(532)), anchor: "west", m("hook refuses code before tasks:approved", size: 9.5, lh: 12))
})

// --- B · The gate as code, with callouts --------------------------------------
#let lines = (
  ("bash", "# .ai/sdd/specs/001-feature/.status   (a human edits it)", none),
  ("token", "requirements:draft", 1),
  ("bash", "# then: requirements:approved -> design:approved", none),
  ("bash", "#       -> tasks:approved", none),
  (none, "", none),
  ("bash", "# AGENTS.md (or CLAUDE.md)", none),
  ("md", "## Development flow", none),
  ("md", "1. Every feature has a spec in `.ai/sdd/specs/NNN-name/`", none),
  ("md", "2. Read the feature's `.status` BEFORE implementing anything", 2),
  ("md", "3. Never write code before `tasks:approved`", 3),
  ("md", "4. Ambiguity during implementation: STOP and ask", none),
  (none, "", none),
  ("bash", "# hook or CI step: block code until the token is there", none),
  ("bash", "grep -qxE 'tasks:approved|implementation:in-progress' \\", 4),
  ("bash", "  \"$SPEC/.status\" || exit 1", none),
)
#let code-lh = 13
#let codeblock = block(width: 100%, fill: ink.bg, radius: 12 * px, inset: (x: 16 * px, y: 12 * px), {
  show raw: set text(font: mono, size: 11 * px, ligatures: false, features: (calt: 0))
  let e = edges(mono, 11, code-lh)
  set text(top-edge: e.top-edge, bottom-edge: e.bottom-edge)
  grid(
    columns: (20 * px, 12 * px, auto, 8 * px, auto),
    rows: code-lh * px,
    align: (right + horizon, left, left + horizon, left, left + horizon),
    ..lines.enumerate().map(((i, (lang, src, b))) => (
      m(pad2(i + 1), size: 9, lh: code-lh, fill: ink.border-strong),
      [],
      if lang == "token" { tx(src, font: mono, size: 11, lh: code-lh, fill: ink.amber-300, weight: 700) }
      else if lang == none { [] }
      else { raw(src, lang: lang, theme: theme) },
      [],
      if b != none { badge(b, size: 13) } else { [] },
    )).flatten(),
  )
})
#let notes = (
  ("the token", "A human edits this line. The agent only reads it."),
  ("read first", "The agent reads .status before any code."),
  ("the rule", "No code before tasks:approved."),
  ("the check", "A check that refuses to run: exit 1."),
)
#let note-row = grid(
  columns: (1fr,) * 4,
  column-gutter: 16 * px,
  ..notes.enumerate().map(((i, (t, b))) => stack(
    stack(dir: ltr, spacing: 8 * px, badge(i + 1, size: 13), box(height: 13 * px, align(horizon, cap(t, fill: ink.amber-400)))),
    v(4 * px),
    // Greedy breaks: the optimizer leaves a two-word first line at 114 px.
    block({ set par(leading: 0pt, linebreaks: "simple"); tx(b, size: 10.5, lh: 14, fill: ink.secondary) }),
  )),
)

// --- C · Sequence ---------------------------------------------------------------
// Labels sit on their arrow, on a chip of the tile colour, so messages can be
// 16 px apart and still keep 4 px of air.
#let sequence = canvas({
  import cetz.draw: *
  let (W, H) = (264, 192)
  let Y(y) = H - y
  let xs = (human: 30, status: 98, agent: 166, hook: 234)
  let heads = (("human", "human"), ("status", ".status"), ("agent", "agent"), ("hook", "hook"))
  for (k, label) in heads {
    let x = xs.at(k)
    line((x, Y(20)), (x, Y(192)), stroke: (paint: ink.border, thickness: 1 * px, dash: (2 * px, 3 * px)))
    rect((x - 30, Y(0)), (x + 30, Y(20)), radius: 4, fill: ink.soft, stroke: none)
    content((x, Y(10)), anchor: "center", cap(label, size: 8.5, fill: if k == "human" { ink.amber-400 } else { ink.paper }))
  }
  let chip(body) = box(fill: ink.card, inset: (x: 3 * px), body)
  let msg(a, b, y, label, paint: ink.border-strong, w: 1.5, dashed: false) = {
    let (xa, xb) = (xs.at(a), xs.at(b))
    let dir = if xb > xa { 1 } else { -1 }
    line((xa, Y(y)), (xb - dir * 2, Y(y)), stroke: (paint: paint, thickness: w * px, dash: if dashed { (3 * px, 2 * px) } else { none }),
      mark: (end: ">", fill: paint, scale: 0.45))
    content(((xa + xb) / 2, Y(y)), anchor: "center", chip(m(label, size: 8.5, lh: 11, fill: if paint == ink.amber-500 { ink.amber-400 } else { ink.secondary })))
  }
  msg("agent", "human", 36, "spec ready", dashed: true)
  msg("human", "status", 52, "approve", paint: ink.amber-500, w: 2)
  msg("agent", "status", 68, "read")
  msg("status", "agent", 84, "approved", dashed: true)
  // alt: the hook answers one of two ways.
  rect((64, Y(100)), (264, Y(188)), radius: 4, fill: none, stroke: 1 * px + ink.border-strong)
  rect((64, Y(100)), (92, Y(112)), fill: ink.border-strong, stroke: none)
  content((78, Y(106)), anchor: "center", m("alt", size: 8, lh: 10, fill: ink.inverse, weight: 700))
  msg("agent", "hook", 124, "commit")
  msg("hook", "status", 140, "grep")
  line((64, Y(150)), (264, Y(150)), stroke: (paint: ink.border-strong, thickness: 1 * px, dash: (2 * px, 2 * px)))
  msg("hook", "agent", 164, "pass")
  content((70, Y(164)), anchor: "west", chip(m("[token]", size: 8, lh: 10, fill: ink.muted)))
  msg("hook", "agent", 178, "exit 1", paint: ink.amber-500, w: 2)
  content((70, Y(178)), anchor: "west", chip(m("[none]", size: 8, lh: 10, fill: ink.muted)))
})

// --- D · On disk ---------------------------------------------------------------
#let tree = canvas({
  import cetz.draw: *
  let (W, H) = (184, 190)
  let Y(y) = H - y
  // (depth, name, note, kind)
  let rows = (
    (0, "your-repo/", none, "dir"),
    (1, "AGENTS.md", "4 rules", "file"),
    (1, ".ai/", none, "dir"),
    (2, "steering/", "4 files", "dir"),
    (2, "sdd/specs/", none, "dir"),
    (3, "001-feature/", none, "dir"),
    (4, ".status", "the gate", "gate"),
    (4, "requirements.md", none, "file"),
    (4, "design.md", none, "file"),
    (4, "tasks.md", none, "file"),
    (4, "review.md", none, "file"),
  )
  let pitch = 17
  let indent = 14
  let cy(i) = 8 + i * pitch
  // Connectors: from each row's parent down to it.
  for (i, (d, name, note, kind)) in rows.enumerate() {
    if d == 0 { continue }
    let p = range(i).rev().find(j => rows.at(j).at(0) == d - 1)
    let px0 = (d - 1) * indent + 4
    line((px0, Y(cy(p) + 8)), (px0, Y(cy(i))), (d * indent, Y(cy(i))), stroke: 1 * px + ink.border-strong)
    let _ = name
  }
  for (i, (d, name, note, kind)) in rows.enumerate() {
    let x = if d == 0 { 0 } else { d * indent + 4 }
    content((x, Y(cy(i))), anchor: "west", m(name, size: 10, lh: 13, fill: if kind == "gate" { ink.amber-300 } else if kind == "dir" { ink.secondary } else { ink.paper }, weight: if kind == "gate" { 700 } else { 400 }))
    if note != none {
      content((W, Y(cy(i))), anchor: "east", cap(note, size: 8.5, fill: if kind == "gate" { ink.amber-400 } else { ink.muted }))
    }
  }
})

// --- Layout -------------------------------------------------------------------
#grid(
  columns: (400 * px, 544 * px),
  column-gutter: 16 * px,
  block(width: 100%, height: 640 * px, {
    place(rect(width: 100%, height: 100%, radius: 16 * px, fill: ink.card))
    place(rect(width: 100%, height: 100%, radius: 16 * px, fill: dots))
    block(inset: 20 * px, {
      panel-head("state × actor", "Who moves the gate.")
      v(16 * px)
      chart
    })
  }),
  grid(
    rows: (368 * px, 256 * px),
    row-gutter: 16 * px,
    tile({
      lbl("the gate as code")
      v(12 * px)
      codeblock
      v(12 * px)
      note-row
    }),
    grid(
      columns: (304 * px, 224 * px),
      column-gutter: 16 * px,
      tile({ lbl("one approval, in order"); v(8 * px); sequence }),
      tile({ lbl("on disk"); v(12 * px); tree }),
    ),
  ),
)
