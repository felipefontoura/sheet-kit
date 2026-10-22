// Base25 dark: the palette, the three voices and the measuring units every
// sheet shares. Sizes are CSS px (1 px = 0.75 pt), so a page drawn in HTML,
// Figma or Claude Design ports with its numbers intact.

#let px = 0.75pt

// felipefontoura.com's tokens (src/styles/global.css). Charcoal grounds, one
// amber ramp: amber is a point of light, not paint.
#let ink = (
  bg: rgb("#14120f"),
  elevated: rgb("#1d1916"),
  card: rgb("#24211e"),
  soft: rgb("#2f2b27"),
  border: rgb("#423d38"),
  border-strong: rgb("#6f675d"),
  paper: rgb("#ece7df"),
  secondary: rgb("#a39a8d"),
  muted: rgb("#6e665c"),
  inverse: rgb("#1a1206"),
  amber-50: rgb("#fdf6e7"),
  amber-100: rgb("#fceac5"),
  amber-200: rgb("#fbd893"),
  amber-300: rgb("#f8c662"),
  amber-400: rgb("#f5b83d"),
  amber-500: rgb("#eda921"),
  amber-600: rgb("#d49311"),
  amber-700: rgb("#ad7a14"),
  amber-800: rgb("#845f15"),
  amber-900: rgb("#5b4415"),
  ok: rgb("#7a9a63"),
  danger: rgb("#c2574e"),
)

// The three voices. Static instances in assets/fonts/ (scripts/fonts.sh),
// pinned to the optical sizes the site renders: Inter opsz 14, Newsreader 16.
#let sans = "Inter"
#let serif = "Newsreader"
#let mono = "JetBrains Mono"

// Ascender and descender (em, OS/2 typo metrics) of each family.
#let metrics = (
  "Inter": (0.96875, 0.2412),
  "Newsreader": (0.735, 0.265),
  "JetBrains Mono": (1.02, 0.3),
)

// Stroke weights by role. A line's weight says what it is, page after page.
#let strokes = (guide: 1 * px, data: 1.5 * px, emph: 2 * px)

// The spacing scale (px). Gaps, insets and offsets come from here.
#let space = (4, 8, 12, 16, 20, 24, 32)

// Page formats (width, height). Letter landscape is the house default:
// it sits on a second monitor and prints on US and A4 paper alike.
#let formats = (
  "letter-landscape": (11in, 8.5in),
  "letter": (8.5in, 11in),
  "a4-landscape": (297mm, 210mm),
  "a4": (210mm, 297mm),
)

// The safe area (px): text never crosses it. scripts/check.py enforces it.
#let margin = (top: 32, bottom: 28, x: 48)
