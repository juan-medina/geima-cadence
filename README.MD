# Geima: Cadence
[![License: MIT](https://img.shields.io/badge/License-MIT-478CBF.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Conduct](https://img.shields.io/badge/Conduct-Covenat%202.0-478CBF.svg?style=for-the-badge)](https://www.contributor-covenant.org/version/2/0/code_of_conduct/)
[![Made with Godot](https://img.shields.io/badge/GODOT-4.7-478CBF?style=for-the-badge&logo=godot%20engine&logoColor=white)](https://godotengine.org)

> **Geima: Cadence** is a rhythm-action endless runner where **the music is your health, and your heartbeat is your shield**. Run, jump, slash, and block to the beat of a high-energy soundtrack to charge your magical escape core and outrun a ruthless empire.


TBC

## Beatmap Generation

Each song needs a beatmap (`src/songs/<song>.json`) that tells the game when obstacles arrive and which action defeats them. Beatmaps are generated from the audio by [scripts/beatmap_generator.py](scripts/beatmap_generator.py) — see the [Beatmap Generation Pipeline](docs/beatmap-generation.md) for how the detection works.

### Setup (one time)

Requires Python. From the repository root:

```powershell
.\scripts\setup_env.ps1
```

This creates a `.venv` and installs the dependencies from `requirements.txt`.

### Usage

```powershell
# defaults: normal difficulty, seed 0 — this is how the current songs are generated
.\scripts\generate_beatmap.ps1 src\songs\Disco_Medusae.mp3

# denser or sparser maps
.\scripts\generate_beatmap.ps1 src\songs\Disco_Medusae.mp3 --difficulty hard
.\scripts\generate_beatmap.ps1 src\songs\Disco_Medusae.mp3 --difficulty easy

# alternative map for the same song (different random choices, still reproducible)
.\scripts\generate_beatmap.ps1 src\songs\Disco_Medusae.mp3 --seed 7
```

The JSON is written next to the audio file. Generation is deterministic: the same song, difficulty, and seed always produce the same beatmap.

### Options and current values

| Option | Default | Notes |
| :--- | :---: | :--- |
| `--difficulty` | `normal` | `easy` (0.85 s min gap), `normal` (0.50 s), `hard` (0.40 s) |
| `--seed` | `0` | Random seed for action tie-breaks |
| `--viewport-width` | `640` | Must match `viewport_width` in [project.godot](src/project.godot) |
| `--hero-x` | `-100` | Must match the Hero position in [game.tscn](src/game/game.tscn) |
| `--scroll-speed` | `250` | Must match `scroll_speed` in [track.gd](src/track/track.gd) |

The last three describe the game's layout and drive the lead-in before the first note (currently `(640/2 + 100) / 250 = 1.68 s`). If any of them change in the game, regenerate the beatmaps with matching values. The minimum gap between notes is floored at 0.40 s because the hero's action animations take 0.35 s.

**Current songs:** `Disco_Medusae.json` was generated with the defaults (`normal`, seed `0`).

Graphics

### Warrior-Free Animation set V1.3
* **Author:** [Clement Baudet](https://clembod.itch.io/)
* **Source:** [Itch.io](https://clembod.itch.io/warrior-free-animation-set)
* **License:** Custom permission (Free for personal and commercial use, modification allowed, redistribution prohibited).

Music


### "Disco Medusae"
* **Author:** [Kevin MacLeod](incompetech.com)
* **Source:** [incompetech](incompetech.com)
* **License:** Creative Commons: By Attribution 4.0 License
http://creativecommons.org/licenses/by/4.0/

## License

This project uses a dual-licensing structure to keep the code open while protecting the game's identity:

* **Source Code:** The programming code in this repository is open-source and licensed under the [MIT License](LICENSE). You are free to study, modify, merge, and use the code in your own projects.
* **Branding & Build:** The name **"Geima: Cadence"**, its branding, logos, and compiled game distributions are protected under our [End-User License Agreemen](EULA.md). You may not redistribute modified builds of the game under the "Chromonia" name or use its official branding for commercial purposes without explicit permission.

---

## Contact

Author: [Juan Medina](https://juan-medina.com) (Copyright © 2026)
[Report bugs or feedback](issues/)