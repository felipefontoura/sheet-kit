# AGENTS.md — sheet-kit

sheet-kit sets fixed-layout infographic pages (cheatsheets, one-pagers,
posters, data reports) in Typst, in the Base25 dark identity of
felipefontoura.com. Sister of [book-kit](https://github.com/felipefontoura/book-kit):
same two-root layout, consumed as a git submodule at `kit/`, the same
`example/run.sh`. book-kit flows Markdown into a book; sheet-kit places
every mark on a fixed page.

The bar is pixel perfect, checked in the renderer people actually use
(macOS Preview), not in the one that is convenient.

## The reference: `example/`

`example/` is the concept book: ten pages that push the kit to its limits
(generative cover, decision ladder, custom glyphs, metro map, alluvial,
packed bubbles, state machine with highlighted code, radar small multiples,
a magazine long-read on a baseline grid, a colophon with QR and specimen).
It is the standard: before building a page, open the example page that
does the nearest thing and follow its patterns. `example/output/` holds the
approved PDF and page PNGs; the build fails when a page drifts from them.

## Layout

```
typst/sheet.typ       the one import for a page: theme, type, layout, marks,
                      pinned packages (cetz 0.5.3, fletcher 0.5.8, tiaoma 0.3.0)
typst/theme.typ       ink palette, voices, metrics, stroke roles, spacing, formats, margins
typst/type.typ        tx / para / m / sf / ss / lbl / eyebrow: text that behaves like CSS
typst/layout.typ      sheet, header, headline, tile, panel-head, source, at; reads sheet.config.json
typst/marks.typ       canvas, frame, badge, arrow, hatch, screen, glow, tuck, ribbon, connected
typst/book.typ        the kit's entry: includes /.build/pages.typ (generated from pages/*.typ)
typst/themes/         Base25 dark syntax theme for code blocks (`code-theme`)
typst/assets/fonts/   Inter, Newsreader, JetBrains Mono static instances + OFL (scripts/fonts.sh)
scripts/build.sh      the pipeline: PDF, PNGs, checks, Preview renders
scripts/check.mjs     the checks (mupdf + pngjs)
scripts/preview.swift renders with CoreGraphics, Preview's engine (macOS)
scripts/fonts.sh      rebuilds the fonts from google/fonts at a pinned commit
example/              the concept book, laid out as a material repo
```

A material repo:

```
my-material/
  kit/                 this repo, as a submodule
  sheet.config.json    name, title, author, label, checked, format
  data.typ             every fact and number the pages draw
  pages/01-*.typ …     one file per page, in order
  output/              the approved PDF and png/ (the regression reference)
```

## Commands

```bash
bash kit/scripts/build.sh                  # PDF + page PNGs + checks
bash kit/scripts/build.sh --page 05        # one page alone: the fast loop
bash kit/scripts/build.sh --preview        # + Preview-engine renders at 1x, 1.5x, 4x (macOS)
bash kit/scripts/build.sh --links          # + request every link in the PDF
bash kit/scripts/build.sh --update-ref     # accept the current render as the reference
bash example/run.sh [same flags]           # the example, staged like a material repo
```

Typst and Node are pinned in `mise.toml` (`mise install`). Never upgrade
Typst casually: a new version can move line breaks; bump it, rebuild, look,
then `--update-ref`.

## A page

```typst
#import "/kit/typst/sheet.typ": *
#import "/data.typ": *

#show: sheet.with(section: "Ecosystem")   // label, date, format: sheet.config.json

#headline("572k stars, four repos.", note: "GitHub stars · 21 Oct 2026")
#v(16 * px)
#grid(columns: (1fr, 1fr), column-gutter: 16 * px,
  tile({ panel-head("Packed bubbles", "Where the attention went."); … }),
  tile({ … }),
)
```

The page number and count come from the build; never write them.

## Rules (each one cost a review round)

Numbers and facts
- Every number comes from `data.typ`. Never type a figure into a page, never
  invent one. A missing value is drawn as missing (a dashed ghost, "no public
  count"), not estimated.

Units and grid
- Sizes are CSS px (`* px`, 1 px = 0.75 pt): pages port from HTML, Figma or
  Claude Design with their numbers.
- Margins 48 px sides, 32 top, 28 bottom (`margin`); the check fails on any
  pixel painted outside them (2 px allowed for glyph overhang).
- Gaps from the scale only: 4, 8, 12, 16, 20, 24, 32 (`space`). Panel inset
  20, gutter 16.
- Everything sits on one grid: panel edges, insets and gutters equal across
  the page; text starts on the same left edge as the chart under it.

Text
- All text goes through `tx` or its voices (`m` mono, `sf` serif, `ss` sans,
  `lbl`, `eyebrow`, `para`). They set the line box like CSS, so baselines
  land where a browser puts them.
- Items in a row share one baseline. A headline and its note are one line
  (`headline`, `panel-head(note:)`), so they cannot drift.
- Symbols (→ ● ✓ ≈ ★ …) live in Inter or JetBrains Mono. Newsreader has none.
  Font fallback is off: a missing glyph would vanish silently, so the build
  compiles once more with fallback on and names any character it caught.
- Mono is set without ligatures (`calt` off): `->` stays two characters.
- Numbers right-aligned in columns; anything centred is truly centred.

Shapes and joins
- No blurred shadows, no blend modes. Preview paints transparency groups as
  a darker slab behind the shape; `--preview` scans for it.
- Shapes that meet overlap, never just touch. Two shapes sharing an edge
  leave an antialiasing hairline in Preview at 1x–2x zoom (the ground shows
  through). Tuck the lower shape `tuck` (2 px) under the upper one: `ribbon`
  does it, and so must any bar, band or block you join by hand.
- A connector between boxes is one line under the whole row (`connected`),
  not pieces between them. Hollow markers on it are filled with the ground
  colour, so the line stops at their edge.
- Stroke weight says what a line is: `strokes.guide` 1 px, `.data` 1.5 px,
  `.emph` 2 px. Same role, same weight, on every page.
- A gradient that meets another shape starts and ends in that shape's colour.
- `frame(w, h)` fixes a cetz canvas's box; otherwise it sizes to its marks
  and placement drifts.

Colour
- Charcoal grounds, one amber ramp (`ink`). Amber is a point of light, not
  paint: one hero per page, the rest in paper, greys and textures (`hatch`,
  `screen`). Categories that must read apart differ in lightness, not hue.

Infographic quality (what passed review, after two that did not)
- One hero element per page, large; supporting visuals smaller. Not a grid
  of equal cards (that reads as a dashboard).
- Prefer a custom glyph that carries several values, taught by a "how to
  read" key, over a library chart (example page 03).
- Use unit texture when counts matter: one mark per unit (1,007 dots for
  1,007 seconds).
- Annotate on the data: a numbered badge or a leader line to the mark, the
  claim in words next to it.
- Every panel ends with a source line (`source`): where the numbers came from
  and how they were normalised.

## Review loop (do all of it before saying "done")

1. `bash kit/scripts/build.sh --page NN` while designing; read the PNG.
2. `bash kit/scripts/build.sh --preview`: every check green.
3. Look at the Preview-engine renders, not only Typst's PNGs:
   `.build/preview/1/` and `1.5/` (seams, hairlines, slabs show at low zoom),
   `4/` (alignment, crop each region full size).
4. Open the PDF in Preview for the human: `open -a Preview dist/<name>.pdf`.
5. A regression failure you meant: `--update-ref`, and say what changed.

## Changing the kit

- A helper born in a page moves into `typst/` when a second page needs it.
  Keep the old behaviour: rebuild `example/` and the regression must stay
  at 0.000, or the change is deliberate and `--update-ref` goes with it.
- Generated files (`.build/`, `dist/`) never go in git. `output/` does: it is
  the approved reference.
- Fonts change only through `scripts/fonts.sh` (pinned google/fonts commit,
  deterministic output).

## Typst gotchas met on the way

- A function parameter named `fill` or `stroke` shadows Typst's own inside
  that function (and cetz's); rename it.
- `{}` and `//` inside a markup block start code and comments: write code
  samples as strings.
- Dictionary keys are strings: `("10": 1)`, not `(10: 1)`.
- Text inside a cetz canvas has no collision avoidance: anchor and offset
  every label, and check the 4x render.
- `raw(theme:)` resolves paths from the calling file: the kit passes the
  theme as bytes (`code-theme`).
- No native baseline grid or column balancing: example page 09 builds both.
- `set page` works inside an `#include`d page (each include starts a page),
  not inside a box or block.
