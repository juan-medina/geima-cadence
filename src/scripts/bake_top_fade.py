import argparse
import os

from PIL import Image

# Shared alpha mask, white RGB so the biome modulates it to its sky colour at
# runtime. Drawn at the design resolution and never scaled, so the dither cells
# land 1:1 on screen pixels.
OUTPUT_PATH = os.path.join("data", "assets", "backgrounds", "top_fade_mask.png")

# Width matches the background layers so the mask tiles seamlessly across an
# ultrawide viewport.
WIDTH = 640

# Total fade depth in design-resolution pixels, and how many discrete alpha
# levels (from opaque at the top to transparent at the bottom) it steps through.
FADE_HEIGHT = 150
TONE_COUNT = 6

# 8x8 ordered-dither thresholds (0..63).
BAYER_8 = [
    [0, 32, 8, 40, 2, 34, 10, 42],
    [48, 16, 56, 24, 50, 18, 58, 26],
    [12, 44, 4, 36, 14, 46, 6, 38],
    [60, 28, 52, 20, 62, 30, 54, 22],
    [3, 35, 11, 43, 1, 33, 9, 41],
    [51, 19, 59, 27, 49, 17, 57, 25],
    [15, 47, 7, 39, 13, 45, 5, 37],
    [63, 31, 55, 23, 61, 29, 53, 21],
]


def bake():
    image = Image.new("RGBA", (WIDTH, FADE_HEIGHT), (255, 255, 255, 0))
    pixels = image.load()
    row_denom = max(FADE_HEIGHT - 1, 1)
    tone_denom = max(TONE_COUNT - 1, 1)
    for y in range(FADE_HEIGHT):
        coverage = 1.0 - y / row_denom
        scaled = coverage * tone_denom
        lower = int(scaled)
        frac = scaled - lower
        for x in range(WIDTH):
            threshold = (BAYER_8[y % 8][x % 8] + 0.5) / 64.0
            tone = lower + 1 if frac > threshold else lower
            tone = min(tone, tone_denom)
            alpha = round(tone / tone_denom * 255)
            pixels[x, y] = (255, 255, 255, alpha)
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    image.save(OUTPUT_PATH)
    print(f"Saved {OUTPUT_PATH} ({WIDTH}x{FADE_HEIGHT}, {TONE_COUNT} tones)")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Bake the shared dithered top-edge fade mask for biomes."
    )
    parser.parse_args()
    bake()
