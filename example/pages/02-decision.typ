#import "/kit/typst/sheet.typ": *

#show: sheet.with(section: "Pick a tool")

#para(tx("Match the process to the cost of being wrong.", font: serif, size: 40, lh: 44, tracking: -0.02em))
#v(8 * px)
#para(tx("Seven ways to run spec-driven development: which to pick, what to type, where the approval lives.", size: 15, lh: 22, fill: ink.secondary))
#v(20 * px)

// Flowchart: questions down the left, the tool for each yes on the right.
#let mix = color.mix((ink.paper, 50%), (ink.secondary, 50%), space: oklab)
#let q(n, body) = box(width: 270 * px, height: 56 * px, inset: (x: 14 * px, y: 6 * px), radius: 10 * px, fill: ink.card, align(horizon, block(spacing: 0pt, {
  set par(leading: 0pt, linebreaks: "optimized")
  tx(str(n), font: mono, size: 12, lh: 19, weight: 500, fill: ink.secondary)
  tx("\u{a0}\u{a0}" + body, size: 14, lh: 19)
})))
#let r(name, note, w: 210, h: 56, flip: false, name-size: 17) = box(width: w * px, height: h * px, inset: (x: 12 * px, y: 6 * px), radius: 10 * px, fill: ink.soft, align(horizon, block(spacing: 0pt, {
  // One HTML paragraph split by <br>: each line also carries the 16 px strut.
  let nm = strut() + tx(name, font: serif, size: name-size, lh: 20, weight: 500)
  let nt = strut() + tx(note, size: 12, lh: 16, fill: mix)
  set par(leading: 0pt)
  if flip { nt; linebreak(); nm } else { nm; linebreak(); nt }
})))

#let flow = block(width: 520 * px, height: 622 * px, spacing: 0pt, {
  at(0, 0, para(tx("Which tool fits you", font: serif, size: 22, lh: 26)))
  at(0, 38, para(eyebrow("Start here", fill: ink.amber-600) + eyebrow(" · if no, go down")))
  at(310, 38, para(eyebrow("If yes")))
  let qs = (
    "Small, solo, low stakes, and you keep the docs current?",
    "Must a human approve before any code? Money, data, health.",
    "Should the editor run the whole flow, nothing to assemble?",
    "Does your team think in roles: product, architecture, QA?",
    "Does a team need one documented pipeline per feature?",
    "What goes wrong today?",
  )
  let rs = (
    ("Plain AGENTS.md", "Install nothing"),
    ("sdd-kit", "Claude Code or Pi. Else p. 6"),
    ("Kiro", "The editor runs the flow"),
    ("BMAD", "Asks before it guesses"),
    ("Spec Kit", "Budget the review time"),
  )
  for (i, body) in qs.enumerate() {
    let y = 66 + i * 84
    at(0, y, q(i + 1, body))
    if i < rs.len() {
      at(310, y, r(..rs.at(i)))
      arrow(270, y + 28, 309, y + 28, fill: ink.amber-600)
    }
    if i < qs.len() - 1 { arrow(135, y + 56, 135, y + 83) }
  }
  // Question 6 branches into three answers.
  arrow(135, 542, 135, 556, head: false)
  arrow(68, 556, 408, 556, head: false)
  for x in (68, 216, 408) { arrow(x, 556, x, 569) }
  at(0, 570, r("OpenSpec", "Forgets decisions", w: 136, h: 52, flip: true))
  at(148, 570, r("Superpowers", "Skips tests, steps", w: 136, h: 52, flip: true))
  at(296, 570, r("OpenSpec + Superpowers", "Both, plus your gate", w: 224, h: 52, flip: true, name-size: 15))
})

// Where each tool keeps the approval.
#let rows = (
  ("AGENTS.md", "plain memory", [Nowhere], [No gate to skip]),
  ("OpenSpec", "spec-first, fluid", [The prompt], [Yes]),
  ("Spec Kit", "ordered pipeline", [The prompt #box[(files checked)]], [Yes]),
  ("Superpowers", "harness-first", [The prompt #box[(HARD-GATE)]], [Yes. It never ran in our test]),
  ("BMAD", "role-first", [The prompt #box[(approval menu)]], [Yes. One line of #box[pre-approval]]),
  ("Kiro", "IDE-native", [A click in the IDE], [Quick Spec skips it. Not tested]),
  ("sdd-kit", "gated kit", text(fill: ink.amber-400)[A .status file on disk], [Only if it ignores its skill]),
)
#let row(cells, fill: none, inset: (x: 12 * px, y: 9 * px)) = block(width: 100%, spacing: 0pt, fill: fill, radius: 8 * px, inset: inset, grid(
  columns: (116 * px, 118 * px, 1fr),
  column-gutter: 10 * px,
  ..cells,
))

#let approval = block(width: 100%, height: 622 * px, spacing: 0pt, {
  para(tx("Where the approval lives", font: serif, size: 22, lh: 26))
  v(12 * px)
  row((para(eyebrow("Tool")), para(eyebrow("Gate lives in")), para(eyebrow("Skippable?"))), inset: (x: 12 * px, top: 0pt, bottom: 10 * px))
  for (i, (t1, t2, g, s)) in rows.enumerate() {
    v(2 * px)
    row(
      (
        stack(para(tx(t1, size: 14, lh: 18, weight: 600)), para(tx(t2, size: 12, lh: 16, fill: ink.secondary))),
        para(tx(g, size: 12.5, lh: 17)),
        para(tx(s, size: 12.5, lh: 17, fill: ink.secondary)),
      ),
      fill: if calc.even(i) { ink.elevated } else { none },
    )
  }
  v(1fr)
  block(width: 100%, height: 136 * px, spacing: 0pt, fill: ink.card, radius: 12 * px, inset: 18 * px, align(horizon, stack(
    spacing: 10 * px,
    para(tx("In all four tools we ran, the approval lived in the prompt. If the gate matters, put it on disk.", font: serif, size: 18, lh: 24)),
    lbl("How, in 14 lines: page 6"),
  )))
})

#grid(columns: (520 * px, 1fr), column-gutter: 36 * px, flow, approval)
