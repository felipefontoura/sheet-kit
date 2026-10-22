## What

<!-- One paragraph: what changes and why. -->

## How it was verified

- [ ] `bash example/run.sh --preview` is green (every check, regression 0.000)
- [ ] If a page changed on purpose: I looked at it in Preview at 1x, 1.5x and 4x, and the PR carries `--update-ref`
- [ ] If a material consumes the kit as a submodule: it still builds

## Design rules check

- [ ] No material-specific strings or numbers in the kit (they come from `sheet.config.json` and `data.typ`)
- [ ] Shapes that meet overlap (`tuck`); no blurred shadows or blend modes
- [ ] Generated outputs (`.build/`, `dist/`) stay out of git
