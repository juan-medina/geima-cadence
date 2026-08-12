"""Generate placeholder storyboard panels at the native 540x360 panel canvas.

They stand in until the artist delivers the real panels, already scaled to the
540x360 canvas, straight into assets/story/.

Run from the data repository (it has its own venv):

    .venv/Scripts/python.exe scripts/build_story_placeholders.py
"""

import os

from PIL import Image, ImageDraw, ImageFont

WIDTH = 540
HEIGHT = 360

BACKGROUND = (0, 0, 0)
BIG = (233, 236, 240)
SUBTITLE = (150, 156, 168)
DIMS = (108, 198, 255)

HERE = os.path.dirname(os.path.abspath(__file__))
SRC_ROOT = os.path.dirname(HERE)
FONT_PATH = os.path.join(SRC_ROOT, "data", "assets", "pixel_ui_theme", "m5x7.ttf")
OUT_DIR = os.path.join(SRC_ROOT, "data", "assets", "story")

PANELS = [
    ("intro_1", "IMAGE 1", "INTRO - PANEL 1", "The Legend & The Betrayal"),
    ("intro_2", "IMAGE 2", "INTRO - PANEL 2", "The Raid & The Chase"),
    ("escape_1", "IMAGE 3", "ESCAPE - PANEL 1", "The Portal Leap"),
    ("escape_2", "IMAGE 4", "ESCAPE - PANEL 2", "A New Dawn"),
    ("secret_1", "IMAGE 5", "SECRET - PANEL 1", "The Overload & Displacement"),
    ("secret_2", "IMAGE 6", "SECRET - PANEL 2", "The Closed Loop"),
]


def centered(draw, text, font, y, color):
    left, top, right, bottom = draw.textbbox((0, 0), text, font=font)
    x = (WIDTH - (right - left)) / 2 - left
    draw.text((x, y), text, font=font, fill=color)


def build_panel(name, big, section, subtitle):
    image = Image.new("RGB", (WIDTH, HEIGHT), BACKGROUND)
    draw = ImageDraw.Draw(image)

    big_font = ImageFont.truetype(FONT_PATH, 64)
    section_font = ImageFont.truetype(FONT_PATH, 28)
    small_font = ImageFont.truetype(FONT_PATH, 20)

    centered(draw, section, section_font, 96, SUBTITLE)
    centered(draw, big, big_font, 136, BIG)
    centered(draw, subtitle, section_font, 204, SUBTITLE)
    centered(draw, "540 x 360 placeholder", small_font, 266, DIMS)

    path = os.path.join(OUT_DIR, name + ".png")
    image.save(path)
    print("wrote", path)


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for name, big, section, subtitle in PANELS:
        build_panel(name, big, section, subtitle)


if __name__ == "__main__":
    main()
