import glob
import os
import re

from PIL import Image

# A horizontal flip pivots on the frame centre, so pad every frame on the right
# to move the centre onto the boots; the same pad on every animation keeps their
# alignment to each other unchanged.
PAD_RIGHT = 37

SOURCE_BASE = "data/raw/Cultist Enemy Pack/Individual Sprite/Big Cultist"
OUTPUT_BASE = "data/raw/custom/big_cultist"
ANIMATIONS = ("Idle", "Attack", "Death")


def natural_sort_key(s):
    return [int(text) if text.isdigit() else text.lower()
            for text in re.split(r"(\d+)", s)]


def pad_animation(name):
    source_dir = os.path.join(SOURCE_BASE, name)
    output_dir = os.path.join(OUTPUT_BASE, name)
    os.makedirs(output_dir, exist_ok=True)

    files = sorted(glob.glob(os.path.join(source_dir, "*.png")), key=natural_sort_key)
    if not files:
        raise ValueError(f"No frames found in {source_dir}")

    for path in files:
        frame = Image.open(path).convert("RGBA")
        padded = Image.new("RGBA", (frame.width + PAD_RIGHT, frame.height), (0, 0, 0, 0))
        padded.paste(frame, (0, 0), frame)
        padded.save(os.path.join(output_dir, os.path.basename(path)))

    print(f"{name}: padded {len(files)} frames -> {output_dir}")


if __name__ == "__main__":
    for anim in ANIMATIONS:
        pad_animation(anim)
