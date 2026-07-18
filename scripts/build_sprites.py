import os
import glob
import json
import argparse
import re
from PIL import Image

def natural_sort_key(s):
    """Sort strings with numbers in a natural way."""
    return [int(text) if text.isdigit() else text.lower()
            for text in re.split(r'(\d+)', s)]

def build_spritesheet(config, debug=False):
    for sheet in config.get("spritesheets", []):
        output_path = sheet.get("output_path")
        rows = sheet.get("rows", [])
        
        if not output_path or not rows:
            print(f"Skipping invalid spritesheet config: {sheet}")
            continue

        if debug:
            print(f"\n--- Building Spritesheet: {output_path} ---")

        row_images = []
        max_width = 0
        max_height = 0
        max_frames = 0

        # Pass 1: Gather files and determine grid size
        for row_idx, pattern in enumerate(rows):
            # Find all matching files and sort them naturally
            files = glob.glob(pattern)
            files.sort(key=natural_sort_key)
            
            if debug:
                print(f"Row {row_idx} pattern '{pattern}' matched {len(files)} files:")
                for f in files:
                    print(f"  -> {os.path.basename(f)}")

            # Load images for this row
            images = []
            for f in files:
                try:
                    img = Image.open(f).convert("RGBA")
                    max_width = max(max_width, img.width)
                    max_height = max(max_height, img.height)
                    images.append(img)
                except Exception as e:
                    print(f"Error loading {f}: {e}")
            
            row_images.append(images)
            max_frames = max(max_frames, len(images))

        if not row_images:
            print(f"No images found for {output_path}. Skipping.")
            continue

        # Pass 2: Create the spritesheet
        sheet_width = max_width * max_frames
        sheet_height = max_height * len(rows)
        
        spritesheet = Image.new("RGBA", (sheet_width, sheet_height), (0, 0, 0, 0))

        for row_idx, images in enumerate(row_images):
            for col_idx, img in enumerate(images):
                # We align top-left in the cell. If frames are different sizes, 
                # you may want to modify this to align bottom-center.
                x = col_idx * max_width
                y = row_idx * max_height
                spritesheet.paste(img, (x, y), img)

        # Ensure output directory exists
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        spritesheet.save(output_path)
        print(f"Saved {output_path} ({sheet_width}x{sheet_height} grid)")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build spritesheets from individual frames.")
    parser.add_argument("--config", default="raw/sprites.json", help="Path to JSON config file")
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
