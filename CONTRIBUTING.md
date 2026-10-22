# Contributing to sheet-kit

Thanks for considering a contribution! This kit sets real materials that
people download, so the bar is: **every change must keep a real material
building and looking right, to the pixel.**

## Setup

```bash
git clone https://github.com/felipefontoura/sheet-kit.git
cd sheet-kit
mise install        # Node + Typst, pinned in mise.toml
npm ci
bash example/run.sh # full pipeline → example/.build/dist/sheet-kit-concepts.pdf + checks
```

If you don't use [mise](https://mise.jdx.dev), install Node ≥ 22 and
[Typst 0.15.1](https://typst.app/docs/) manually and make sure both are on
`PATH`. `--preview` needs macOS (it renders with CoreGraphics, Preview's
engine).

## How to verify a change

1. `bash example/run.sh` must pass every check. The concept book
   intentionally exercises every mark (custom glyphs, metro map, alluvial,
   packed bubbles, state machine, code blocks, radar, a baseline-grid
   long-read, QR) and the regression compares it, pixel by pixel, with
   `example/output/`. CI runs exactly this.
2. **Look at the output.** Layout bugs don't throw errors. On macOS run
   `bash example/run.sh --preview` and read the renders in
   `example/.build/.build/preview/` at 1x and 1.5x (seams, hairlines, slabs)
   and 4x (alignment), then open the PDF in Preview.
3. If you can, rebuild a real material that consumes the kit as a submodule
   (`bash kit/scripts/build.sh` from the material root).
4. If your change is meant to move pixels, refresh the reference with
   `bash example/run.sh --update-ref` and say in the PR what changed and why.

## Design rules

These are the invariants that keep the kit portable and the pages exact.
PRs that break them won't be merged:

- **No material-specific strings or numbers in the kit.** Labels, dates and
  formats come from the material's `sheet.config.json`; facts from its
  `data.typ`.
- **Two roots.** `KIT_ROOT` (the kit, read-only) vs `PROJECT_ROOT` (the
  material, receives all generated output). See `scripts/build.sh`.
- **Generated files never enter git**: `.build/`, `dist/`.
- **The rules in [AGENTS.md](AGENTS.md) hold for the kit itself**: px units,
  shared baselines, shapes that overlap at joins, no blurred shadows, symbols
  only in fonts that have them.
- **Visual identity lives in the kit** (`typst/theme.typ`, the voices in
  `typst/type.typ`): per-material deviations go through parameters, not forks.

## Commit style

Conventional commits, as in the existing history: `feat:`, `fix:`, `docs:`,
`ci:`, `refactor:` — imperative mood, subject ≤ 72 chars.

## Reporting bugs

Use the bug template and include the **smallest page** that reproduces the
problem, and where it shows (Typst's PNG, Preview at 1x, a check). Rendering
bugs without a repro page are very hard to act on.
