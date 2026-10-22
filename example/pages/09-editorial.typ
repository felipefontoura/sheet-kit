#import "/kit/typst/sheet.typ": *
#import "/data.typ": *

#show: sheet.with(section: "Long read")

// Baseline grid: 18 px. Body Newsreader 13/18. Every block in the columns is
// a whole number of grid lines, so the three columns share baselines.
// Page: top band 180 (10 lines) | body 540 (30 lines).
// Body: rail 176 | 16 | article 768 = 3 × 240 + 2 × 24.

#let L = 18
#let body-size = 13
#let col-w = 240
#let grid-e = edges(serif, body-size, L) // the grid's baseline, for every voice
#let on-grid(body, font: serif, size: body-size, fill: ink.paper, weight: 400, style: "normal", tracking: 0em) = text(
  font: font, size: size * px, fill: fill, weight: weight, style: style, tracking: tracking,
  top-edge: grid-e.top-edge, bottom-edge: grid-e.bottom-edge, features: if font == mono { (calt: 0) } else { (:) }, body)

// Display text that keeps the grid: its first baseline lands where a body
// line's would, and each further line advances `lines` grid lines.
#let on-pitch(body, lines: 2, ..args) = text(..args, top-edge: grid-e.top-edge, bottom-edge: -(lines * L * px - grid-e.top-edge), body)

// Inline voices inside the running text.
#let code(s) = on-grid(s, font: mono, size: 11, fill: ink.amber-300)
#let fn(n) = super(typographic: true, text(fill: ink.amber-400, str(n)))
// Faux small caps: Newsreader ships no smcp, so caps at 78% with tracking.
#let sc(s) = on-grid(upper(s), size: body-size * 0.78, tracking: 0.06em, weight: 500)
// An inline bar: a tool's cost, to the scale of the dearest run.
#let bar(cost) = box(width: cost / 2.84 * 28 * px, height: 6 * px, radius: 1 * px, fill: ink.amber-600, baseline: 0pt)
#let price(cost) = box[#code("$" + str(cost))#h(3 * px)#bar(cost)]

#let subhead(t) = {
  v(L * px, weak: true)
  block(height: L * px, spacing: 0pt, on-grid(upper(t), font: mono, size: 9.5, fill: ink.amber-400, tracking: 0.08em, weight: 500))
}

// --- Top band (10 lines) ---------------------------------------------------------
// Left: kicker 1 · headline 4 · standfirst 3 · byline 1 · gap 1 (lines of 18).
// Right: two numbers and the run date, the date on the byline's baseline.
#let meta(body) = block(height: 18 * px, align(bottom, para(m(body, size: 10, lh: 14, fill: ink.muted, tr: 0.04em))))
#let stat(big, note) = grid(columns: (104 * px, 1fr), column-gutter: 12 * px, align: (right + bottom, left + bottom),
  para(sf(big, size: 44, lh: 48, fill: ink.amber-400)),
  block(height: 48 * px, align(bottom, block(inset: (bottom: 8 * px), para(m(note, size: 9.5, lh: 13, fill: ink.secondary))))),
)
#grid(columns: (696 * px, 240 * px), column-gutter: 24 * px, rows: 180 * px,
  {
    block(height: 18 * px, lbl("Field notes · spec-driven development"))
    block(height: 72 * px, para(sf([Where #text(fill: ink.amber-400, style: "italic")[approval] lives.], size: 62, lh: 72)))
    block(height: 54 * px, para(sf("Four spec-driven tools ran the same brief. The code converged, the bills ran 8.6 times apart, and in every run the step that mattered most sat where the agent could skip it.", size: 18, lh: 27, fill: ink.secondary, style: "italic")))
    meta("By Felipe Fontoura · AI Engineer")
  },
  {
    v(18 * px)
    stat("4/4", "tools kept the gate in the prompt")
    v(24 * px)
    stat("8.6×", "apart on cost for the same feature")
    v(1fr)
    meta("Run 13 Oct 2026 · checked " + checked)
    v(18 * px)
  },
)

// --- The drop cap -------------------------------------------------------------------
// Cap height spans three lines: its top on line 1's cap line, its baseline on
// line 3's. Size = (2 L + cap height of the body) / cap-height ratio (0.67).
#let cap-ratio = 0.67
#let cap-size = (2 * L + body-size * cap-ratio) / cap-ratio
#let baseline-1 = grid-e.top-edge // from the top of line 1 to its baseline
#let cap-top = baseline-1 - body-size * cap-ratio * px
#let dropcap(letter, runin, rest-words, after) = context {
  let cap = text(font: serif, size: cap-size * px, fill: ink.amber-400, top-edge: "cap-height", bottom-edge: "baseline", letter)
  let indent = measure(cap).width + 8 * px
  let narrow = col-w * px - indent
  let lead(k) = [#sc(runin) #rest-words.slice(0, k).join(" ")]
  // The longest prefix of words that still sets in three lines.
  let fits(k) = measure(block(width: narrow, lead(k))).height <= 3 * L * px + 0.1pt
  let k = 0
  while k < rest-words.len() and fits(k + 1) { k += 1 }
  block(spacing: 0pt, {
    place(top + left, dy: cap-top, cap)
    pad(left: indent, block(width: narrow, spacing: 0pt, [#lead(k)#linebreak(justify: true)]))
    set par(first-line-indent: 0pt)
    [#rest-words.slice(k).join(" ")#after]
  })
}

// --- Figure: the four bills (8 lines) ------------------------------------------
// Rows are grid lines; each label is a grid-line box centred on its row, so its
// baseline is the body's.
#let figure-bills = block(height: 8 * L * px, spacing: 0pt, {
  canvas({
    import cetz.draw: *
    let (W, H) = (240, 90)
    let Y(y) = H - y
    rect((0, 0), (W, H), stroke: none, fill: none)
    let lab(body, fill: ink.secondary, size: 9.5) = on-grid(body, font: mono, size: size, fill: fill)
    let x0 = 84
    let span = 120 // $3 → 120 px
    for v in (0, 1, 2, 3) {
      let x = x0 + v / 3 * span
      line((x, Y(0)), (x, Y(72)), stroke: (paint: ink.border, thickness: 1 * px, dash: if v == 0 { none } else { (1 * px, 2 * px) }))
      content((x, Y(81)), anchor: "center", lab("$" + str(v), fill: ink.muted, size: 8.5))
    }
    for (i, r) in run.enumerate() {
      let cy = 9 + i * 18
      content((x0 - 8, Y(cy)), anchor: "east", lab(r.name, fill: if r.asked { ink.paper } else { ink.secondary }))
      rect((x0, Y(cy - 5)), (x0 + r.cost / 3 * span, Y(cy + 5)), radius: 2, fill: if r.asked { ink.amber-600 } else { ink.border-strong }, stroke: none)
      content((x0 + r.cost / 3 * span + 6, Y(cy)), anchor: "west", lab("$" + str(r.cost), fill: ink.paper))
    }
  })
  v(L * px)
  block(height: 2 * L * px, {
    set par(justify: false, leading: 0pt)
    on-grid(upper("Fig. 1  "), font: mono, size: 9, fill: ink.amber-400, tracking: 0.06em)
    on-grid([API-equivalent cost of one brief, 13 Oct 2026. Amber: the tool asked before coding.], size: 11, style: "italic", fill: ink.secondary)
  })
})

// --- Pull quote (7 lines) ------------------------------------------------------
#let pull-quote = block(height: 7 * L * px, spacing: 0pt, breakable: false, {
  // The rule sits on the cap line of the neighbouring columns' first line.
  block(height: L * px, place(dy: grid-e.top-edge - body-size * 0.67 * px - 1 * px, line(length: 48 * px, stroke: 2 * px + ink.amber-500)))
  block({
    set par(justify: false, leading: 0pt, linebreaks: "optimized")
    on-pitch(lines: 2, font: serif, size: 26 * px, style: "italic", fill: ink.amber-300)[The agent can misread a rule. It can't argue with an exit code.]
  })
})

// --- The tokens (7 lines) -------------------------------------------------------
#let token-box = block(height: 7 * L * px, width: 100%, fill: ink.elevated, radius: 8 * px, inset: (x: 12 * px), spacing: 0pt, breakable: false, {
  set par(justify: false, leading: 0pt)
  let row(n, tok, who) = grid(columns: (20 * px, 1fr, auto),
    on-grid(str(n), font: mono, size: 9, fill: ink.muted),
    on-grid(tok, font: mono, size: 10.5, fill: if who == "you" { ink.amber-300 } else { ink.paper }),
    on-grid(upper(who), font: mono, size: 8.5, fill: if who == "you" { ink.amber-400 } else { ink.muted }, tracking: 0.06em),
  )
  on-grid(upper("The five tokens, in order"), font: mono, size: 9, fill: ink.amber-400, tracking: 0.08em, weight: 500)
  linebreak()
  for (i, t) in tokens.enumerate() {
    row(i + 1, t, if t.ends-with(":approved") { "you" } else if i == 0 { "draft" } else { "exec" })
  }
  on-grid([The hook passes on 4 and 5 only.], size: 11.5, style: "italic", fill: ink.secondary)
})

// --- Article -----------------------------------------------------------------------
#let p1-rest = "a twenty-four line file, two tests, one base commit, and a request for an idempotent transfer with a key. Two questions were left open on purpose: is the key required, and does a failed transfer use it up?".split(" ")

#let article = {
  set text(font: serif, size: body-size * px, fill: ink.paper, top-edge: grid-e.top-edge, bottom-edge: grid-e.bottom-edge, lang: "en", hyphenate: true, costs: (widow: 1000%, orphan: 1000%, runt: 300%, hyphenation: 120%))
  set par(justify: true, leading: 0pt, spacing: 0pt, first-line-indent: (amount: 13 * px, all: false), linebreaks: "optimized",
    // Microtypography: words may tighten to 75% and letters track ±1%, so the
    // narrow measure justifies without rivers.
    justification-limits: (spacing: (min: 75%, max: 135%), tracking: (min: -0.01em, max: 0.012em)))
  // Tool names never break across lines.
  show regex("Superpowers|OpenSpec|Spec Kit|AGENTS\.md"): it => box(it)
  columns(3, gutter: 24 * px, {
    dropcap("I", "n all four tools we ran,", ("the", "approval", "lived", "in", "the", "prompt.", "That", "sentence", "is", "the", "whole", "finding,", "and", "it", "took", "a", "ledger", "to", "get", "there:") + p1-rest, [])

    parbreak()
    [#h(13 * px)Each tool got a fresh clone, the same model and Claude Code 2.1.296, run headless. Spec Kit spent the most: #price(2.84) over 473 seconds and ten prompts, with 690 lines of spec. OpenSpec came in at #price(2.16), BMAD at #price(1.89) and Superpowers at #price(0.33), in 40 seconds and two prompts.#fn(1) The code converged anyway. Three tools passed all 13 acceptance checks; OpenSpec passed 12.]

    subhead("Who asked first")
    [Only BMAD asked both open questions before writing code, and it recommended the right answer: the key is required. Spec Kit asked before the plan, then recommended the wrong one. OpenSpec asked nothing and guessed, but flagged it before code. Superpowers decided the key was required on its own and said so after the code, because its brainstorming step never loaded.]

    colbreak()
    pull-quote

    subhead("A prompt can be argued with")
    [Every one of those tools keeps its gate in text the agent reads. OpenSpec stops after a proposal and waits for your OK. Spec Kit refuses to implement until #code("plan.md") and #code("tasks.md") exist, but a one-line plan passes. Superpowers puts a HARD-GATE in its brainstorming skill. BMAD offers an approval menu the agent marks itself, and one line of pre-approval skips it. These are instructions, and an instruction is something a model weighs. Kiro moves the gate into its editor: a human click between phases, which no check can read.]

    subhead("A file cannot")
    [A file on disk is different. Give each feature a #code(".status") file that only a human edits, with one token per phase.#fn(2) Tell the agent, in AGENTS.md, to read it before implementing anything and never to write code before #code("tasks:approved"). Then add what a prompt cannot give you: a hook or CI step that greps the file and exits 1 when the token is missing.#fn(3)]

    v(L * px)
    figure-bills

    v(L * px, weak: true)
    token-box

    subhead("What the totals hide")
    [Two details never reach a total. Spec Kit's analyze step caught four of its own tests that would pass before the feature existed. Superpowers, run by hand, asked first.]

    parbreak()
    [#h(13 * px)None of this needs a new tool. sdd-kit ships the #code(".status") file and the skills that read it; the hook is yours. Pick the lightest process that closes your gap, then decide where the yes is written down.#h(4 * px)#box(width: 7 * px, height: 7 * px, fill: ink.amber-500)]
  })
}

// --- Rail: margin notes and footnotes --------------------------------------------
#let rail-label(t) = block(height: L * px, spacing: 0pt, on-grid(upper(t), font: mono, size: 9, fill: ink.amber-400, tracking: 0.08em, weight: 500))
#let rail-text(body) = block(spacing: 0pt, {
  set par(justify: false, leading: 0pt, linebreaks: "optimized")
  on-grid(body, size: 11.5, style: "italic", fill: ink.secondary)
})
#let where = (("nowhere", "AGENTS.md"), ("prompt", "OpenSpec, Spec Kit, Superpowers, BMAD"), ("IDE", "Kiro"), ("disk", "sdd-kit"))
#let rail-row(key, body, key-fill: ink.muted, body-fill: ink.secondary, key-w: 56) = grid(
  columns: (key-w * px, 1fr),
  block({ set par(leading: 0pt); on-grid(key, font: mono, size: 9, fill: key-fill, tracking: 0.04em) }),
  block({ set par(justify: false, leading: 0pt); on-grid(body, size: 11.5, fill: body-fill) }),
)
#let rail = block(width: 176 * px, height: 540 * px, spacing: 0pt, {
  rail-label("The run")
  rail-text[13 Oct 2026. claude-opus-5-5 in Claude Code 2.1.296, headless, a fresh clone per tool, scored on the same 13-item check.]
  v(L * px)
  rail-label("The brief")
  rail-text[An in-memory ledger: a 24-line #on-grid("src/ledger.js", font: mono, size: 10, fill: ink.paper), two tests, one base commit. Add an idempotent #on-grid("transfer()", font: mono, size: 10, fill: ink.paper) with a key.]
  v(L * px)
  rail-label("Where the gate lives")
  for (place-name, who) in where {
    rail-row(upper(place-name), who, key-fill: if place-name == "disk" { ink.amber-400 } else { ink.muted }, body-fill: if place-name == "disk" { ink.paper } else { ink.secondary })
  }
  v(L * px)
  rail-label("Seconds to a pass")
  for r in run {
    grid(columns: (80 * px, 1fr), align: (left, left + horizon),
      block({ set par(leading: 0pt); on-grid(r.name, font: mono, size: 9, fill: ink.secondary) }),
      box(height: L * px, align(horizon, stack(dir: ltr, spacing: 4 * px,
        box(width: r.time / 473 * 56 * px, height: 6 * px, radius: 1 * px, fill: if r.asked { ink.amber-600 } else { ink.border-strong }),
        on-grid(str(r.time), font: mono, size: 9, fill: ink.paper)))),
    )
  }
  v(1fr)
  rail-label("Notes")
  let notes = (
    "API-equivalent cost. n = 1.",
    "Status values: the book, 3.5.",
    "The hook is ours, not the book's.",
  )
  for (i, n) in notes.enumerate() {
    rail-row(str(i + 1), n, key-fill: ink.amber-400, key-w: 16)
  }
})

#grid(columns: (176 * px, 768 * px), column-gutter: 16 * px, rail, block(height: 540 * px, spacing: 0pt, article))
