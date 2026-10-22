// Verified facts (checked 2026-10-21 against the live repos, npm and docs;
// the head-to-head ran on 2026-10-13). Every page draws from here, so a
// number is right everywhere or wrong everywhere. Sources: the cheatsheet's
// data.md (tags A, B, L-gh, L-npm, L-web).

// The check date lives in sheet.config.json (the running head reads it too).
#let checked = json("/sheet.config.json").checked

// The 13 Oct run: same brief, Claude Code 2.1.296, claude-opus-5-5, n = 1.
#let run = (
  (name: "Spec Kit", version: "1.2.0", cost: 2.84, time: 473, prompts: 10, spec-lines: 690, tokens: 3.80, checks: 13, asked: true, decision: "Recommended optional (wrong)", right: false),
  (name: "OpenSpec", version: "1.14.1", cost: 2.16, time: 277, prompts: 6, spec-lines: 136, tokens: 2.15, checks: 12, asked: false, decision: "Guessed optional, flagged it before code", right: false),
  (name: "BMAD", version: "6.12.2", cost: 1.89, time: 217, prompts: 3, spec-lines: 88, tokens: 1.88, checks: 13, asked: true, decision: "Recommended required (right)", right: true),
  (name: "Superpowers", version: "7.0.0", cost: 0.33, time: 40, prompts: 2, spec-lines: 0, tokens: 0.23, checks: 13, asked: false, decision: "Decided required, said so after the code", right: true),
)

// The tools on 21 Oct 2026. stars in thousands; agents = named integrations.
#let tools = (
  (name: "OpenSpec", center: "spec-first, fluid", version: "1.14.3", released: "2026-10-17", stars: 72.6, license: "MIT", agents: 45, gate: "prompt", skip: "yes"),
  (name: "Spec Kit", center: "spec-first, ordered pipeline", version: "1.2.2", released: "2026-10-19", stars: 142.3, license: "MIT", agents: 41, gate: "prompt", skip: "yes"),
  (name: "Superpowers", center: "harness-first", version: "7.0.0", released: "2026-10-10", stars: 303.0, license: "MIT", agents: none, gate: "prompt", skip: "yes"),
  (name: "BMAD", center: "role-first", version: "6.12.4", released: "2026-10-14", stars: 54.0, license: "MIT", agents: none, gate: "prompt", skip: "yes"),
  (name: "Kiro", center: "IDE-native", version: "IDE 1.4.10 · CLI 2.32.0", released: none, stars: none, license: "proprietary", agents: none, gate: "IDE", skip: "yes"),
  (name: "sdd-kit", center: "gated kit", version: "0.1.0", released: none, stars: none, license: "MIT", agents: none, gate: "disk", skip: "hard"),
  (name: "AGENTS.md", center: "plain memory", version: none, released: none, stars: none, license: none, agents: none, gate: "nowhere", skip: "no gate"),
)

// Each tool's workflow, in order (the cheatsheet's pages 2 to 4).
#let workflows = (
  "OpenSpec": ("explore", "propose", "update", "apply", "sync", "archive"),
  "Spec Kit": ("constitution", "specify", "plan", "tasks", "implement", "converge"),
  "Superpowers": ("brainstorming", "worktrees", "writing-plans", "subagents", "TDD", "code review", "finish branch"),
  "BMAD": ("help", "build", "prd", "architecture", "build (story)", "retrospective"),
  "Kiro": ("requirements", "design", "tasks", "run"),
  "sdd-kit": ("init", "steering", "prd", "spec", "tasks", "exec", "review"),
)

// The .status gate tokens (book 3.5), in order.
#let tokens = ("requirements:draft", "requirements:approved", "design:approved", "tasks:approved", "implementation:in-progress")

// Each run tool's colour, the same on every page: lightness steps on the
// amber ramp, paper for the fastest. Needs the kit's `ink` in scope.
#let tool-ink(ink) = ("Spec Kit": ink.amber-700, "OpenSpec": ink.amber-500, "BMAD": ink.amber-300, "Superpowers": ink.paper)
