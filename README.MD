# Geima: Cadence
[![License: MIT](https://img.shields.io/badge/License-MIT-478CBF.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Conduct](https://img.shields.io/badge/Conduct-Covenat%202.0-478CBF.svg?style=for-the-badge)](https://www.contributor-covenant.org/version/2/0/code_of_conduct/)
[![Made with Godot](https://img.shields.io/badge/GODOT-4.7-478CBF?style=for-the-badge&logo=godot%20engine&logoColor=white)](https://godotengine.org)
[![Play on itch.io](https://img.shields.io/badge/itch.io-Play-478CBF?style=for-the-badge&logo=itchdotio&logoColor=white)](https://juanmedina.itch.io/geima-cadence)

<p align="center">
  <a href="https://juanmedina.itch.io/geima-cadence"><img src="screens/cover.jpg" alt="Geima: Cadence — play on itch.io"></a>
</p>

>**Geima: Cadence** is a rhythm-action endless runner. There's no rhythm highway - the world itself is your timeline. Enemies and hazards rush in from the right, and you answer each one with the correct move, exactly on the beat, to charge the Geima Core in your pack and tear open a portal to freedom.
>
>Miss a beat and you don't fall- you falter. The run never stops, the music never breaks.


**[Play on itch.io →](https://juanmedina.itch.io/geima-cadence)** — play in your browser, or download for Windows, Linux, and macOS.

Chasing the bleeding edge? The [latest dev build](https://juan-medina.github.io/geima-cadence/) auto-deploys from `main` for testers.

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
* **License:** Custom permission (Free for personal and commercial use, modification allowed, redistribution prohibited). The set was purchased to support the author.

#### Cultist Enemy Pack
* **Author:** [Clement Baudet](https://clembod.itch.io/)
* **Source:** [Itch.io](https://clembod.itch.io/cultist-enemy-pack)
* **License:** Paid. Used under a purchased license (personal and commercial use
  allowed, modification allowed, redistribution and resale prohibited).

#### Shoggoth
* **Author:** [Clement Baudet](https://clembod.itch.io/)
* **Source:** [Itch.io](https://clembod.itch.io/shoggoth)
* **License:** Paid. Used under a purchased license (personal and commercial use
  allowed, modification allowed, redistribution and resale prohibited).

#### Kenney Game Assets All-in-1
* **Author:** [Kenney](https://kenney.nl/)
* **Source:** [Itch.io](https://kenney.itch.io/kenney-game-assets)
* **License:** [Creative Commons Zero (CC0 1.0)](https://creativecommons.org/publicdomain/zero/1.0/) — public domain, free for personal and commercial use. The pack was purchased to support the author.

#### Dark Fantasy Backgrounds
* **Author:** [Arludus](https://arludus.itch.io/)
* **Source:** [Itch.io](https://arludus.itch.io/dark-fantasy-backgrounds)
* **License:** Paid. Used under a purchased license (free for use in games,
  including commercial ones; the pack itself may not be resold or
  redistributed).

#### Pixel UI Theme for Godot
* **Author:** [Pelatho](https://thowsenmedia.itch.io/)
* **Source:** [Itch.io](https://thowsenmedia.itch.io/pixel-ui-theme-for-godot)
* **License:** Paid. Used under a purchased license (personal and commercial use
  allowed for one or more projects; redistribution and resale prohibited).

#### Godot CRT Shader
* **Author:** [Henrique Alves (perons)](https://perons.itch.io/)
* **Source:** [Itch.io](https://perons.itch.io/godot-crt-shader)
* **License:** Free for personal and commercial use. The shader was purchased to support the author.

### Music

#### 16-Bit Fantasy & Adventure Music Pack
* **Author:** [Marllon Silva (xDeviruchi)](https://xdeviruchi.itch.io/)
* **Source:** [Itch.io](https://xdeviruchi.itch.io/16-bit-fantasy-adventure-music-pack)
* **License:** Free (name-your-own-price). Personal and commercial use allowed;
  minor edits allowed; redistribution, resale, and OST releases prohibited.
  Attribution optional but appreciated. Purchased to support the author.

#### 16-Bit Fantasy: Battles Music Pack
* **Author:** [Marllon Silva (xDeviruchi)](https://xdeviruchi.itch.io/)
* **Source:** [Itch.io](https://xdeviruchi.itch.io/16-bit-fantasy-battles-music-pack)
* **License:** Paid. Used under a purchased license (personal and commercial
  use allowed; minor edits allowed; redistribution, resale, and OST releases
  prohibited). Attribution optional but appreciated.

### Sound Effects

#### Modern UI SFX
* **Author:** [Leohpaz](https://www.patreon.com/cw/leohpaz)
* **Source:** [Itch.io](https://leohpaz.itch.io/modern-ui-sfx)
* **License:** Paid. Used under a purchased license (personal and commercial use
  allowed; the pack may not be resold or redistributed). Attribution is optional
  but appreciated. Used for UI sound effects.

#### 90+ RPG Battle SFX
* **Author:** [Leohpaz](https://www.patreon.com/cw/leohpaz)
* **Source:** [Itch.io](https://leohpaz.itch.io/90-rpg-battle-sfx)
* **License:** Paid. Used under a purchased license (personal and commercial use
  allowed; the pack may not be resold or redistributed). Attribution is optional
  but appreciated.

#### 90+ Retro Player Movement SFX
* **Author:** [Leohpaz](https://www.patreon.com/cw/leohpaz)
* **Source:** [Itch.io](https://leohpaz.itch.io/90-retro-player-movement-sfx)
* **License:** Paid. Used under a purchased license (personal and commercial use
  allowed; the pack may not be resold or redistributed). Attribution is optional
  but appreciated.

#### Minifantasy - True Heroes IV SFX
* **Author:** [Leohpaz](https://www.patreon.com/cw/leohpaz)
* **Source:** [Itch.io](https://leohpaz.itch.io/minifantasy-true-heroes-iv-sfx)
* **License:** Paid. Used under a purchased license (personal and commercial use
  allowed; the pack may not be resold or redistributed). Attribution is optional
  but appreciated.

#### Minifantasy - Creatures SFX Pack
* **Author:** [Leohpaz](https://www.patreon.com/cw/leohpaz)
* **Source:** [Itch.io](https://leohpaz.itch.io/minifantasy-creatures-sfx-pack)
* **License:** Paid. Used under a purchased license (personal and commercial use
  allowed; the pack may not be resold or redistributed). Attribution is optional
  but appreciated.

#### 50+ RPG Battle Magic SFX
* **Author:** [Leohpaz](https://www.patreon.com/cw/leohpaz)
* **Source:** [Itch.io](https://leohpaz.itch.io/50-rpg-battle-magic-sfx)
* **License:** Paid. Used under a purchased license (personal and commercial use
  allowed; the pack may not be resold or redistributed). Attribution is optional
  but appreciated.

#### Fake Vintage Computer Terminal Text Output Bleeps
* **Author:** [subetha2026](https://freesound.org/people/subetha2026/)
* **Source:** [Freesound](https://freesound.org/people/subetha2026/sounds/843291/)
* **License:** [Creative Commons Zero (CC0 1.0)](https://creativecommons.org/publicdomain/zero/1.0/) — public domain, free for personal and commercial use.

### Fonts

#### m5x7
* **Author:** [Daniel Linssen](https://managore.itch.io/)
* **Source:** [Itch.io](https://managore.itch.io/m5x7)
* **License:** [Creative Commons Zero (CC0 1.0)](https://creativecommons.org/publicdomain/zero/1.0/) — public domain, free for personal and commercial use. The font was purchased to support the author.

## Testers

Huge thanks to everyone who played the game and helped shape it with their feedback:

* [Adirtan](https://open.spotify.com/user/11155600083)
* [RightBigChimken](https://rightbigchimken.carrd.co/)
* [Yunc4](https://www.twitch.tv/yunc4)

And to everyone who gives the game a run — thank you for playing!


## License

This project uses a dual-licensing structure to keep the code open while protecting the game's identity:

* **Source Code:** The programming code in this repository is open-source and licensed under the [MIT License](LICENSE). You are free to study, modify, merge, and use the code in your own projects. The MIT license covers the source code only — it grants no rights to any game asset.
* **Assets:** Game assets are not part of this repository and are not covered by the MIT license. Each is a third-party work governed by its own license terms, as listed in [Credits](#credits).
* **Branding & Build:** The name **"Geima: Cadence"**, its branding, logos, and compiled game distributions are protected under our [End-User License Agreement](EULA.MD). You may not redistribute modified builds of the game under the "Geima: Cadence" name or use its official branding for commercial purposes without explicit permission.

---

## Contact

Author: [Juan Medina](https://juan-medina.com) (Copyright © 2026)
[Report bugs or feedback](issues/)