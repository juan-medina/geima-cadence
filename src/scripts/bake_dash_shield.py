import argparse
import glob
import math
import os
import re

from PIL import Image

# Pack frames are read-only source; derived frames go to raw/custom, so a pack
# update can replace raw/Warrior and a re-run rebuilds the shield on top.
SOURCE_GLOB = "data/raw/Warrior/Individual Sprite/Dash/*.png"
OUTPUT_DIR = "data/raw/custom/dash_shield"

# Front half-dome radius; its top clears the head by HEAD_CLEARANCE pixels.
FORWARD_RADIUS = 19
HEAD_CLEARANCE = 3

# Radians past the vertical the arc extends at each end.
ARC_END = 1.66

# Per-frame reveal fraction (0..1), clipped from the back; the dome never moves
# or resizes.
REVEALS = [0.45, 0.75, 1.0, 1.0, 1.0, 0.75, 0.5]

# Reveals below this are dithered every other row.
DITHER_BELOW = 0.6

# Front to back: white leading edge, then the core's blues.
EDGE = (232, 246, 255, 255)
LIGHT = (122, 192, 255, 255)
MID = (52, 128, 222, 255)


def natural_sort_key(s):
    return [int(text) if text.isdigit() else text.lower()
            for text in re.split(r'(\d+)', s)]


def draw_dome(img, cx, cy, rx, ry, reveal, dither):
    """reveal clips the arc by x from the back: 1.0 draws the whole dome, smaller
    values keep only the front part, so the shape never moves or resizes.
    """
    back_x = cx + rx * math.cos(ARC_END)
    clip_x = (cx + rx) - reveal * (cx + rx - back_x)
    a = -ARC_END
    while a <= ARC_END:
        for depth, color in enumerate((EDGE, LIGHT, MID)):
            x = round(cx + (rx - depth) * math.cos(a))
            y = round(cy + (ry - depth) * math.sin(a))
            if x < clip_x:
                continue
            if dither and y % 2 == 0:
                continue
            if 0 <= x < img.width and 0 <= y < img.height:
                img.putpixel((x, y), color)
        a += 0.02


def bake(debug=False):
    files = sorted(glob.glob(SOURCE_GLOB), key=natural_sort_key)
    if not files:
        raise SystemExit(f"No frames matched {SOURCE_GLOB}")
    if len(files) != len(REVEALS):
        raise SystemExit(
            f"Expected {len(REVEALS)} dash frames, found {len(files)}; "
            "update REVEALS to match the pack"
        )

    os.makedirs(OUTPUT_DIR, exist_ok=True)

    for path, reveal in zip(files, REVEALS):
        img = Image.open(path).convert("RGBA")
        left, top, right, bottom = img.getbbox()
        cx = (left + right) / 2
        bottom_tip = img.height - 1
        ry = (bottom_tip - (top - HEAD_CLEARANCE)) / 2
        cy = bottom_tip - ry
        draw_dome(img, cx, cy, FORWARD_RADIUS, ry, reveal, reveal < DITHER_BELOW)

        out_path = os.path.join(OUTPUT_DIR, os.path.basename(path))
        img.save(out_path)
        if debug:
            print(f"{os.path.basename(path)}: dome x={cx:.0f}..{cx + FORWARD_RADIUS:.0f}, "
                  f"y={cy - ry:.0f}..{bottom_tip}, reveal={reveal}")
        print(f"Saved {out_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Bake the energy dome onto the dash frames."
    )
    parser.add_argument("--debug", action="store_true", help="Print dome placement")
    args = parser.parse_args()
    bake(debug=args.debug)
