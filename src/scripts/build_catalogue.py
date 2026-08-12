import argparse
import json
import os
import re
import sys

from difficulty_sim import ARCHETYPES, REFERENCE_ARCHETYPE, build_chart, miss_probabilities

# Ordering key = expected misses a reference player makes on this tier's chart
# (from difficulty_sim).
SORT_DIFFICULTY = "normal"
REFERENCE = next(archetype for archetype in ARCHETYPES if archetype.name == REFERENCE_ARCHETYPE)


def load_json(path):
    if not os.path.exists(path):
        print(f"Error: file not found: {path}")
        sys.exit(1)
    with open(path, encoding="utf-8") as handle:
        return json.load(handle)


def read_song(entry):
    stem = os.path.splitext(os.path.basename(entry["output"]))[0]
    beatmap_path = os.path.join("assets", "songs", f"{stem}.json")
    beatmap = load_json(beatmap_path)
    tier = beatmap["difficulties"].get(SORT_DIFFICULTY, {})
    chart = build_chart(stem, entry["name"], SORT_DIFFICULTY, tier.get("actions", []))
    difficulty = float(miss_probabilities(chart, REFERENCE).sum()) if chart else 0.0
    return {
        "id": stem,
        "name": entry["name"],
        "bpm": round(beatmap["tempo"]),
        "metric": difficulty,
    }


def biome_song_counts(song_total, biome_total):
    base, remainder = divmod(song_total, biome_total)
    return [base + (1 if index >= biome_total - remainder else 0)
            for index in range(biome_total)]


# The header (resource uid and script ext_resources) is reused verbatim so the
# script uids stay matched to the current game code.
def read_header(path):
    if not os.path.exists(path):
        print(f"Error: existing catalogue not found: {path}")
        sys.exit(1)
    text = open(path, encoding="utf-8").read()
    markers = [pos for pos in (text.find("[sub_resource"), text.find("[resource]"))
               if pos != -1]
    if not markers:
        print(f"Error: {path} has no resource body to anchor the header.")
        sys.exit(1)
    header = text[:min(markers)].rstrip() + "\n\n"

    ext_ids = {}
    for line in header.splitlines():
        if not line.startswith("[ext_resource"):
            continue
        path_match = re.search(r'path="res://catalogue/(\w+)\.gd"', line)
        id_match = re.search(r'\bid="([^"]+)"', line)
        if path_match and id_match:
            ext_ids[path_match.group(1)] = id_match.group(1)
    for script in ("song_entry", "biome_entry", "catalogue"):
        if script not in ext_ids:
            print(f"Error: {path} is missing the {script}.gd ext_resource.")
            sys.exit(1)
    return header, ext_ids


def render(header, ext_ids, biomes, groups):
    song_ext = ext_ids["song_entry"]
    biome_ext = ext_ids["biome_entry"]
    cat_ext = ext_ids["catalogue"]
    blocks = [header]

    for songs in groups:
        for song in songs:
            blocks.append(
                f'[sub_resource type="Resource" id="Song_{song["id"]}"]\n'
                f'script = ExtResource("{song_ext}")\n'
                f'id = &"{song["id"]}"\n'
                f'name = "{song["name"]}"\n'
                f'bpm = {song["bpm"]}\n\n'
            )

    for biome, songs in zip(biomes, groups):
        refs = ", ".join(f'SubResource("Song_{song["id"]}")' for song in songs)
        blocks.append(
            f'[sub_resource type="Resource" id="Biome_{biome["id"]}"]\n'
            f'script = ExtResource("{biome_ext}")\n'
            f'id = {biome["id"]}\n'
            f'name = "{biome["name"]}"\n'
            f'songs = Array[ExtResource("{song_ext}")]([{refs}])\n'
            f'floor_offset = {biome["floor_offset"]}\n\n'
        )

    biome_refs = ", ".join(f'SubResource("Biome_{biome["id"]}")' for biome in biomes)
    blocks.append(
        "[resource]\n"
        f'script = ExtResource("{cat_ext}")\n'
        f'biomes = Array[ExtResource("{biome_ext}")]([{biome_refs}])\n'
    )
    return "".join(blocks)


def main():
    parser = argparse.ArgumentParser(
        description="Generate catalogue.tres: distribute songs across biomes by chart difficulty."
    )
    parser.add_argument("--songs", default=os.path.join("scripts", "config", "songs.json"))
    parser.add_argument("--biomes", default=os.path.join("scripts", "config", "biomes.json"))
    parser.add_argument("--output",
                        default=os.path.join("assets", "catalogue", "catalogue.tres"))
    args = parser.parse_args()

    songs = [read_song(entry) for entry in load_json(args.songs)["songs"]]
    songs.sort(key=lambda song: (song["metric"], song["id"]))

    biomes = sorted(load_json(args.biomes)["biomes"], key=lambda biome: biome["id"])
    if not biomes:
        print("Error: biomes.json has no biomes.")
        sys.exit(1)

    counts = biome_song_counts(len(songs), len(biomes))
    groups = []
    cursor = 0
    for count in counts:
        groups.append(songs[cursor:cursor + count])
        cursor += count

    header, ext_ids = read_header(args.output)
    text = render(header, ext_ids, biomes, groups)

    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    with open(args.output, "w", encoding="utf-8", newline="\n") as handle:
        handle.write(text)

    for biome, songs_in_biome in zip(biomes, groups):
        print(f"{biome['name']}:")
        for song in songs_in_biome:
            print(f"  misses {song['metric']:.2f}  {song['id']:<22} bpm {song['bpm']}")
    print(f"\nWrote {args.output}")


if __name__ == "__main__":
    main()
