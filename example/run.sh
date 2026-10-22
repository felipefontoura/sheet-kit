#!/usr/bin/env bash
# Build the example (the concept book) exactly as a material repo would:
# stage a throwaway root with the kit mounted at kit/ (submodule layout),
# then run the normal pipeline inside it. Outputs land in example/.build/dist/.
#
# Usage: bash example/run.sh [--pdf | --png | --all] [--preview] [--links] [--update-ref]
#        --update-ref also refreshes example/output/ (the committed reference)
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"   # example/
KIT="$(cd "$HERE/.." && pwd -P)"                          # repo root
STAGE="$HERE/.build"

rm -rf "$STAGE/kit" "$STAGE/pages"
mkdir -p "$STAGE/kit"

# Example content → stage root (the material repo)
tar -C "$HERE" --exclude=.build --exclude=run.sh -cf - . | tar -xf - -C "$STAGE"

# Kit → stage/kit (the "submodule")
tar -C "$KIT" --exclude=.git --exclude=node_modules --exclude=example -cf - . \
  | tar -xf - -C "$STAGE/kit"

# Reuse the kit's installed deps if present (build.sh installs them otherwise)
[[ -d "$KIT/node_modules" ]] && ln -sfn "$KIT/node_modules" "$STAGE/kit/node_modules"

cd "$STAGE"
bash kit/scripts/build.sh "$@"

# --update-ref rewrote the stage's output/: carry it back to the example.
if [[ " $* " == *" --update-ref "* ]]; then
  rm -rf "$HERE/output" && cp -R "$STAGE/output" "$HERE/output"
  echo "   example/output/ refreshed"
fi

echo ""
echo "Outputs in $STAGE/dist/"
