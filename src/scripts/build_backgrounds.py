import os
import argparse
import json
from PIL import Image

# Source layers are 1920x1080, downscaled 3x to the 640x360 design resolution
# and renamed to the loader's bg_<biome>_layer_<m> scheme.
RAW_LAYERS_DIR = os.path.join(
    "data", "raw", "2D Pixel Art Dark Fantasy Backgrounds Pack", "Layers 1920x1080"
)

RAW_PREVIEW_DIR = os.path.join(
    "data", "raw", "2D Pixel Art Dark Fantasy Backgrounds Pack", "Full texture 480x270"
)

OUTPUT_DIR = os.path.join("data", "assets", "backgrounds")
TARGET_SIZE = (640, 360)

# 320x180 = the stage-select carousel's min size.
PREVIEW_SIZE = (320, 180)

BIOMES_MANIFEST = os.path.join("scripts", "config", "biomes.json")


def load_biome_sources():
    with open(BIOMES_MANIFEST, encoding="utf-8") as handle:
        manifest = json.load(handle)
    return {entry["id"]: entry["source_bg"] for entry in manifest["biomes"]}


def build_backgrounds(resample):
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    for biome, source in sorted(load_biome_sources().items()):

        src_path = os.path.join(RAW_PREVIEW_DIR, f"BG Dark Fantasy {source}.png")
        if not os.path.exists(src_path):
            break
        image = Image.open(src_path).convert("RGBA")
        image = image.resize(PREVIEW_SIZE, resample)
        dst_path = os.path.join(OUTPUT_DIR, f"bg_{biome}_preview.png")
        image.save(dst_path)
        print(f"BG preview {source}: -> {dst_path}")

        layer = 1
        while True:
            src_path = os.path.join(RAW_LAYERS_DIR, f"BG{source} Layer{layer}.png")
            if not os.path.exists(src_path):
                break
            image = Image.open(src_path).convert("RGBA")
            image = image.resize(TARGET_SIZE, resample)
            dst_path = os.path.join(OUTPUT_DIR, f"bg_{biome}_layer_{layer}.png")
            image.save(dst_path)
            print(f"BG{source} Layer{layer} -> {dst_path}")
            layer += 1
        if layer == 1:
            print(f"Warning: no layers found for pack BG{source} in {RAW_LAYERS_DIR}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Scale and rename the chosen pack backgrounds into the game's biome layers."
    )
    parser.add_argument(
        "--nearest",
        action="store_true",
        help="Use nearest-neighbour instead of Lanczos (crisper pixels, more aliasing).",
    )
    args = parser.parse_args()

    resample = Image.Resampling.NEAREST if args.nearest else Image.Resampling.LANCZOS
    build_backgrounds(resample)
