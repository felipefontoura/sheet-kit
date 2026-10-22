// The kit's entry: every page of the material, in file order, as one
// document (fonts embedded once). scripts/build.sh writes /.build/pages.typ
// from pages/*.typ, so a material is just its pages: add a file, it's in.
#let cfg = json("/sheet.config.json")
// No creation date: the same sources give the same bytes, so a published
// version can be checked for changes by hash (and builds are reproducible).
#set document(title: cfg.at("title", default: cfg.name), author: cfg.at("author", default: ()), date: none)
#include "/.build/pages.typ"
