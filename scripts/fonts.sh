#!/usr/bin/env bash
# Rebuild typst/assets/fonts/ from the variable masters in google/fonts, pinned to one
# commit so the instances (and every page's line breaks) never drift.
# Needs curl and uv. Usage: bash scripts/fonts.sh
set -euo pipefail
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
COMMIT="45e3d5269e4a17d823f6d84470bc084dc5ae46f6" # google/fonts main, 2026-10-21
BASE="https://raw.githubusercontent.com/google/fonts/$COMMIT/ofl"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

fetch() { curl -fsSL -o "$TMP/$2" "$BASE/$1"; }
fetch "inter/Inter%5Bopsz,wght%5D.ttf" Inter-VF.ttf
fetch "inter/Inter-Italic%5Bopsz,wght%5D.ttf" Inter-Italic-VF.ttf
fetch "newsreader/Newsreader%5Bopsz,wght%5D.ttf" Newsreader-VF.ttf
fetch "newsreader/Newsreader-Italic%5Bopsz,wght%5D.ttf" Newsreader-Italic-VF.ttf
fetch "jetbrainsmono/JetBrainsMono%5Bwght%5D.ttf" JetBrainsMono-VF.ttf
fetch "jetbrainsmono/JetBrainsMono-Italic%5Bwght%5D.ttf" JetBrainsMono-Italic-VF.ttf

mkdir -p "$KIT/typst/assets/fonts"
uvx --from 'fonttools[woff]' python "$KIT/scripts/fonts.py" "$TMP" "$KIT/typst/assets/fonts"
for fam in inter newsreader jetbrainsmono; do
  curl -fsSL -o "$KIT/typst/assets/fonts/OFL-$fam.txt" "$BASE/$fam/OFL.txt"
done
echo "typst/assets/fonts/ rebuilt from google/fonts@${COMMIT:0:7}"
