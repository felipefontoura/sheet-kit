// sheet-kit: fixed-layout infographic pages in Typst. One import gives a
// page everything: `#import "/kit/typst/sheet.typ": *` (or "/typst/sheet.typ"
// inside this repo). Packages are pinned here and re-exported, so every page
// draws with the same versions.
#import "@preview/cetz:0.5.3"
#import "@preview/fletcher:0.5.8"
#import "@preview/tiaoma:0.3.0"
#import "theme.typ": *
#import "type.typ": *
#import "layout.typ": *
#import "marks.typ": *

// The syntax theme for code blocks: Base25 dark, `raw(theme: code-theme)`.
// Read here as bytes, so it resolves from any page wherever the kit sits.
#let code-theme = read("themes/base25-dark.tmTheme", encoding: none)
