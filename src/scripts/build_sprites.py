import os
import glob
import json
import math
import argparse
import re
from PIL import Image

# The tooling runs from src/ (Godot's project root), so a file's path relative to
# src/ is also its res:// address. Packed sheets are binary and live in the data
# submodule (data/assets/...); the .tres atlases are authored source (assets/...).
RES_PREFIX = "res://"

# SpriteFrames stores the loop mode as an int; these are the names used in the config.
LOOP_MODES = {False: 0, True: 1, "pingpong": 2}


def natural_sort_key(s):
    return [int(text) if text.isdigit() else text.lower()
            for text in re.split(r'(\d+)', s)]


def res_path(path):
    normalized = path.replace("\\", "/")
    if normalized.startswith("./"):
        normalized = normalized[2:]
    return RES_PREFIX + normalized


def read_import_uid(png_path):
    """The uid Godot gave the sheet on import, so the .tres can reference it by uid."""
    import_path = png_path + ".import"
    if not os.path.exists(import_path):
        return None
    with open(import_path, "r") as f:
        for line in f:
            match = re.match(r'uid="(uid://[^"]+)"', line.strip())
            if match:
                return match.group(1)
    return None


def read_own_uid(tres_path):
    """Godot stamps a uid the first time it saves the resource; rebuilding must keep it,
    or every scene referencing this file falls back to the path with a warning."""
    if not os.path.exists(tres_path):
        return None
    with open(tres_path, "r") as f:
        match = re.search(r'uid="(uid://[^"]+)"', f.readline())
    return match.group(1) if match else None


def choose_columns(frame_count, cell_width, cell_height):
    best_columns = 1
    best_difference = None
    for columns in range(1, frame_count + 1):
        rows = math.ceil(frame_count / columns)
        difference = abs(columns * cell_width - rows * cell_height)
        if best_difference is None or difference < best_difference:
            best_difference = difference
            best_columns = columns
    return best_columns


def format_speed(frame_count, duration):
    speed = frame_count / duration
    text = f"{speed:.6f}".rstrip("0").rstrip(".")
    return text if "." in text else text + ".0"


def write_sprite_frames(tres_path, png_path, animations):
    sheet_uid = read_import_uid(png_path)
    own_uid = read_own_uid(tres_path)

    header = '[gd_resource type="SpriteFrames" format=3'
    if own_uid:
        header += f' uid="{own_uid}"'
    header += "]"

    ext = '[ext_resource type="Texture2D"'
    if sheet_uid:
        ext += f' uid="{sheet_uid}"'
    ext += f' path="{res_path(png_path)}" id="1_sheet"]'

    lines = [header, "", ext, ""]

    # Godot's editor re-saves animation blocks sorted by name; emit in that order
    # so an editor save produces no diff.
    for anim in sorted(animations, key=lambda a: a["name"]):
        for index, (x, y, width, height) in enumerate(anim["regions"]):
            lines.append(f'[sub_resource type="AtlasTexture" id="{anim["name"]}_{index}"]')
            lines.append('atlas = ExtResource("1_sheet")')
            lines.append(f"region = Rect2({x}, {y}, {width}, {height})")
            lines.append("")

    lines.append("[resource]")

    # Sorted by name here as well, to match the blocks above.
    entries = []
    for anim in sorted(animations, key=lambda a: a["name"]):
        frames = ", ".join(
            '{\n"duration": 1.0,\n"texture": SubResource("%s_%d")\n}' % (anim["name"], i)
            for i in range(len(anim["regions"]))
        )
        entries.append(
            '{\n"frames": [%s],\n"loop": %d,\n"name": &"%s",\n"speed": %s\n}'
            % (
                frames,
                LOOP_MODES[anim["loop"]],
                anim["name"],
                format_speed(len(anim["regions"]), anim["duration"]),
            )
        )
    lines.append("animations = [" + ", ".join(entries) + "]")

    with open(tres_path, "w", newline="\n") as f:
        f.write("\n".join(lines) + "\n")

    print(f"Saved {tres_path} ({len(animations)} animations)")


def build_spritesheet(config, debug=False):
    for sheet in config.get("spritesheets", []):
        output_path = sheet.get("output_path")
        animations = sheet.get("animations", [])
        padding = sheet.get("padding", 0)

        if not output_path or not animations:
            print(f"Skipping invalid spritesheet config: {sheet}")
            continue

        if debug:
            print(f"\n--- Building Spritesheet: {output_path} ---")

        max_width = 0
        max_height = 0
        packed = []

        for anim in animations:
            for key in ("name", "duration", "loop", "frames"):
                if key not in anim:
                    raise ValueError(f"Animation in {output_path} is missing '{key}': {anim}")
            if anim["loop"] not in LOOP_MODES:
                raise ValueError(
                    f"Animation '{anim['name']}' has unknown loop '{anim['loop']}'; "
                    f"expected one of {sorted(LOOP_MODES, key=str)}"
                )
            if not anim["duration"] > 0:
                raise ValueError(f"Animation '{anim['name']}' needs a duration above zero")

            files = glob.glob(anim["frames"])
            files.sort(key=natural_sort_key)

            if debug:
                print(f"Animation '{anim['name']}' matched {len(files)} files:")
                for f in files:
                    print(f"  -> {os.path.basename(f)}")

            images = []
            for f in files:
                try:
                    img = Image.open(f).convert("RGBA")
                    max_width = max(max_width, img.width)
                    max_height = max(max_height, img.height)
                    images.append(img)
                except Exception as e:
                    print(f"Error loading {f}: {e}")

            if not images:
                raise ValueError(f"Animation '{anim['name']}' matched no frames")

            anim["regions"] = []
            for img in images:
                packed.append((anim, img))

        cell_width = max_width + padding * 2
        cell_height = max_height + padding * 2
        columns = choose_columns(len(packed), cell_width, cell_height)
        rows = math.ceil(len(packed) / columns)

        spritesheet = Image.new(
            "RGBA", (columns * cell_width, rows * cell_height), (0, 0, 0, 0)
        )

        for index, (anim, img) in enumerate(packed):
            cell_x = (index % columns) * cell_width
            cell_y = (index // columns) * cell_height
            # The source canvas already carries inter-frame alignment; paste at a
            # fixed offset and never re-center.
            spritesheet.paste(img, (cell_x + padding, cell_y + padding), img)
            anim["regions"].append((cell_x, cell_y, cell_width, cell_height))

        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        spritesheet.save(output_path)
        print(
            f"Saved {output_path} ({spritesheet.width}x{spritesheet.height}, "
            f"{len(packed)} frames in {columns}x{rows} cells of {cell_width}x{cell_height})"
        )

        tres_path = os.path.splitext(output_path)[0].replace("data/assets/", "assets/") + ".tres"
        os.makedirs(os.path.dirname(tres_path), exist_ok=True)
        write_sprite_frames(tres_path, output_path, animations)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build spritesheets from individual frames.")
    parser.add_argument("--config", default="scripts/config/sprites.json", help="Path to JSON config file")
    parser.add_argument("--debug", action="store_true", help="Print packed files in order")
    args = parser.parse_args()

    try:
        with open(args.config, "r") as f:
            config = json.load(f)
        build_spritesheet(config, debug=args.debug)
    except FileNotFoundError:
        print(f"Error: Could not find config file '{args.config}'")
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}")
