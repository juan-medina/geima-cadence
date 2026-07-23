# Geima: Cadence
[![License: MIT](https://img.shields.io/badge/License-MIT-478CBF.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Conduct](https://img.shields.io/badge/Conduct-Covenat%202.0-478CBF.svg?style=for-the-badge)](https://www.contributor-covenant.org/version/2/0/code_of_conduct/)
[![Made with Godot](https://img.shields.io/badge/GODOT-4.7-478CBF?style=for-the-badge&logo=godot%20engine&logoColor=white)](https://godotengine.org)

> **Geima: Cadence** is a rhythm-action endless runner where **the music is your health, and your heartbeat is your shield**. Run, jump, slash, and block to the beat of a high-energy soundtrack to charge your magical escape core and outrun a ruthless empire.

## ▶ Play now

**[Play in your browser →](https://juan-medina.github.io/geima-cadence/)** — no download required.

TBC

## Assets

Game assets are not distributed with this source. They are third-party works governed by their own license terms, credited below, and several of them may not be redistributed — so they live in a separate, private repository referenced here as a git submodule at `src/data`.

Each release of the game pins the exact asset revision it was built with, so any tagged version can be rebuilt with the assets it originally shipped.

```bash
git clone --recurse-submodules <this-repo>

# already cloned without submodules
git submodule update --init
```

The submodule is private: without access, the clone succeeds but `src/data` stays empty and the project will not run. The credits below list every asset used and where it came from, so the set can be reassembled from the original sources. Arrange them as `assets/songs/` and `assets/sprites/` inside `src/data`.

Each song also needs a beatmap: a JSON file next to the audio, named after it, describing when each obstacle arrives and which action defeats it. [track.gd](src/track/track.gd) reads that file and places the obstacles along the track.

## Credits

### Graphics

#### Warrior-Free Animation set V1.3
* **Author:** [Clement Baudet](https://clembod.itch.io/)
* **Source:** [Itch.io](https://clembod.itch.io/warrior-free-animation-set)
* **License:** Custom permission (Free for personal and commercial use, modification allowed, redistribution prohibited).

#### Cultist Enemy Pack
* **Author:** [Clement Baudet](https://clembod.itch.io/)
* **Source:** [Itch.io](https://clembod.itch.io/cultist-enemy-pack)
* **License:** Paid. Used under a purchased license (personal and commercial use
  allowed, modification allowed, redistribution and resale prohibited). The
  sprites are not included in this repository and are not covered by the MIT
  license.

#### Shoggoth
* **Author:** [Clement Baudet](https://clembod.itch.io/)
* **Source:** [Itch.io](https://clembod.itch.io/shoggoth)
* **License:** Paid. Used under a purchased license (personal and commercial use
  allowed, modification allowed, redistribution and resale prohibited). The
  sprites are not included in this repository and are not covered by the MIT
  license.

#### Kenney Game Assets All-in-1
* **Author:** [Kenney](https://kenney.nl/)
* **Source:** [Itch.io](https://kenney.itch.io/kenney-game-assets)
* **License:** [Creative Commons Zero (CC0 1.0)](https://creativecommons.org/publicdomain/zero/1.0/) — public domain, free for personal and commercial use. The pack was purchased to support the author.

#### Dark Fantasy Backgrounds
* **Author:** [Arludus](https://arludus.itch.io/)
* **Source:** [Itch.io](https://arludus.itch.io/dark-fantasy-backgrounds)
* **License:** Paid. Used under a purchased license (free for use in games,
  including commercial ones; the pack itself may not be resold or
  redistributed). The backgrounds are not included in this repository and are
  not covered by the MIT license.

### Music

#### RPG Music Essentials
* **Author:** [Allen J. Mills](https://allenjmills.itch.io/)
* **Source:** [Itch.io](https://allenjmills.itch.io/rpg-music-essentials)
* **License:** Paid, royalty-free ("Unlimited Royalty-free Use"). Used under a
  purchased license. The audio is not included in this repository and may not
  be redistributed; it is not covered by the MIT license.


## License

This project uses a dual-licensing structure to keep the code open while protecting the game's identity:

* **Source Code:** The programming code in this repository is open-source and licensed under the [MIT License](LICENSE). You are free to study, modify, merge, and use the code in your own projects. The MIT license covers the source code only — it grants no rights to any game asset.
* **Assets:** Game assets are not part of this repository and are not covered by the MIT license. Each is a third-party work governed by its own license terms, as listed in [Credits](#credits).
* **Branding & Build:** The name **"Geima: Cadence"**, its branding, logos, and compiled game distributions are protected under our [End-User License Agreement](EULA.MD). You may not redistribute modified builds of the game under the "Geima: Cadence" name or use its official branding for commercial purposes without explicit permission.

---

## Contact

Author: [Juan Medina](https://juan-medina.com) (Copyright © 2026)
[Report bugs or feedback](issues/)