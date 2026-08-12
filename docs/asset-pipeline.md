# Asset Pipeline

The tooling that turns raw art and audio into the assets the game loads lives in
`src/scripts/` and is **run from `src/`** (Godot's project root). A file's path
relative to `src/` is also its `res://` address, and it is the path the scripts
and their manifests use.

The split between authored source and paid binaries follows the repository split
(see `.agents/AGENTS.md` §0):

- **Paid packs and stems** are read from `data/raw/...` (the private data submodule).
- **Binary outputs** (spritesheets, songs, sounds, backgrounds) are written to
  `data/assets/...` (also private).
- **Authored resources** (sprite `.tres` atlases, beatmap `.json` charts) are
  written to `assets/...` in this public repository.

Driver manifests live beside the scripts in `src/scripts/config/`.

## Setup (one time)

Requires Python. From `src/`:

```powershell
.\scripts\setup_env.ps1
```

This creates `src/.venv` and installs the dependencies from
`scripts/requirements.txt`. [ffmpeg](https://ffmpeg.org) must be on `PATH` for the
song and sound builders.

## Sprite Packing

Spritesheets are built from individual frames. `scripts/config/sprites.json`
defines each sheet: its output path, its padding, and one entry per animation.
Each animation is one row of the grid and carries the name the game plays it by,
how long a single play takes, and whether it loops.

```json
{ "name": "dash", "duration": 0.35, "loop": false, "frames": "./data/raw/Warrior/Individual Sprite/Dash/*.png" }
```

| Field | Notes |
| :--- | :--- |
| `frames` | Glob matching the frames, sorted naturally |
| `name` | What the game passes to `play()` |
| `duration` | Seconds for one play, whatever the frame count |
| `loop` | `false` plays once, `true` loops, `"pingpong"` runs back and forth |

The packed PNG goes to `data/assets/sprites/` (private binary); alongside it the
script writes a `SpriteFrames` resource of the same name to `assets/sprites/`
(public authored source) — `hero.png` in the submodule, `hero.tres` here —
holding every animation with its frames, speed and loop mode already set. The
game's `AnimatedSprite2D` points at that `.tres`, which references the sheet at
`res://data/assets/sprites/...`. Adding an animation is one line in the config and
a rebuild; nothing is assembled by hand in the editor.

Because `duration` is in seconds rather than frames per second, adding a frame to
an animation does not change how long it takes — the script recomputes the speed.
Do not edit the generated `.tres` in the editor; the next build overwrites it.

Frames are packed one after another into as square a sheet as the cell size
allows. A sheet's `padding` sets the transparent gutter left around each frame, in
pixels. Frames are placed at a fixed offset and never re-anchored — the artist's
canvas already carries the alignment between frames, so recentring them would
replace that with a guess.

```powershell
.\scripts\build_sprites.ps1

# list the packed files in order
.\scripts\build_sprites.ps1 --debug

# use an alternative config
.\scripts\build_sprites.ps1 --config scripts/config/sprites.json
```

Row order in the config determines row order in the sheet, which the game's
animations depend on — changing it means updating the animation frame ranges in
the game.

## Song Building

Songs arrive as WAV, sometimes as a single file and sometimes split into an intro
and a main part. `scripts/build_songs.py`, driven by `scripts/config/songs.json`,
joins the parts in the order given, normalises and fades each track, and writes
the OGG the game plays to `data/assets/songs/`.

```powershell
.\scripts\build_songs.ps1

# a single song from an ad-hoc manifest
.\scripts\build_songs.ps1 --manifest scripts\config\songs.json
```

Each manifest entry names its `input`/`loop` stems under `data/raw/songs/` and its
`output` OGG under `data/assets/songs/`. All parts of a song must share the same
sample rate and channel count, as they come from the same master; the script stops
if they do not.

Once the OGG exists, generate its beatmap from it.

## Beatmap Generation

Each song needs a beatmap chart (`assets/songs/<song>.json`) that tells the game
when obstacles arrive and which action defeats them. Charts are generated from the
audio by `scripts/beatmap_generator.py` — the audio is read from
`data/assets/songs/` and the chart is written to `assets/songs/` (public source, so
the charts are editable and a modder can author custom levels).

```powershell
# generate for every song under data/assets/songs
.\scripts\generate_all_beatmaps.ps1

# a single song, defaults (seed 0)
.\scripts\generate_beatmap.ps1 data\assets\songs\01_for_hope.ogg

# alternative map for the same song (different random choices, still reproducible)
.\scripts\generate_beatmap.ps1 data\assets\songs\01_for_hope.ogg --seed 7
```

Generation is deterministic: the same song and seed always produce the same chart.

### Options and current values

| Option | Default | Notes |
| :--- | :---: | :--- |
| `--seed` | `0` | Random seed for action tie-breaks |
| `--max-gap` | 4 beats | Longest allowed silence between notes, in seconds (default depends on the song's tempo) |
| `--outro-time` | `6.0` | Trailing seconds left without notes at the end |

The chart's lead-in before the first note is driven by the game's layout
(viewport width, hero position, scroll speed); if those change in the game,
regenerate the charts. Beat strength is judged against neighbouring beats (not the
whole song) so quiet sections still get notes, and any silence longer than
`--max-gap` is filled with the strongest available beat.
