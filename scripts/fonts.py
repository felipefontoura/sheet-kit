# Static font instances for Typst, which reads no variable fonts. Pinned to
# the optical sizes the site renders (Inter opsz 14, Newsreader opsz 16), so
# text sets with the same widths as the web pages.
#   uvx --from 'fonttools[woff]' python scripts/fonts.py <variable-dir> <out-dir>
import os
import sys

from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

src, out = sys.argv[1], sys.argv[2]
PLAN = [
    ("Inter-VF.ttf", "Inter", {"opsz": 14}, [400, 500, 600, 700], False),
    ("Inter-Italic-VF.ttf", "Inter", {"opsz": 14}, [400, 500, 600], True),
    ("Newsreader-VF.ttf", "Newsreader", {"opsz": 16}, [400, 500, 600], False),
    ("Newsreader-Italic-VF.ttf", "Newsreader", {"opsz": 16}, [400, 500, 600], True),
    ("JetBrainsMono-VF.ttf", "JetBrains Mono", {}, [400, 500, 700], False),
    ("JetBrainsMono-Italic-VF.ttf", "JetBrains Mono", {}, [400], True),
]
NAMES = {400: "Regular", 500: "Medium", 600: "SemiBold", 700: "Bold"}

for file, family, pins, weights, italic in PLAN:
    for w in weights:
        f = instancer.instantiateVariableFont(TTFont(os.path.join(src, file)), {**pins, "wght": w})
        style = NAMES[w] if not italic else ("Italic" if w == 400 else NAMES[w] + " Italic")
        n = f["name"]
        # One clean family per voice; OS/2 weight and style drive selection.
        for rec in list(n.names):
            if rec.nameID in (1, 2, 4, 6, 16, 17, 21, 22, 25):
                n.removeNames(nameID=rec.nameID)
        ps = family.replace(" ", "") + "-" + style.replace(" ", "")
        n.setName(family, 1, 3, 1, 0x409)
        n.setName(style, 2, 3, 1, 0x409)
        n.setName(family + " " + style, 4, 3, 1, 0x409)
        n.setName(ps, 6, 3, 1, 0x409)
        f["OS/2"].usWeightClass = w
        sel = f["OS/2"].fsSelection & ~0b1100001
        f["OS/2"].fsSelection = sel | (1 if italic else 0) | (0 if italic or w != 400 else 0b1000000)
        if "STAT" in f:
            del f["STAT"]
        # Keep the master's timestamp: the same commit gives the same bytes.
        f.recalcTimestamp = False
        f.save(os.path.join(out, ps + ".ttf"))
        print(ps)
