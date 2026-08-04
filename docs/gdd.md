# Game Design Document (GDD)
**Project Title:** Geima: Cadence
**Saga / Franchise Name:** The Geima Saga (Earth + Blood)
**Genre:** Rhythm Action / Endless Runner / Arcade-RPG
**Platform:** PC

---

## 1. Executive Summary & Core Concept

### The Pitch
> **Geima: Cadence** is a high-stakes, rhythm-action endless runner where
> **every step is a heartbeat, and your momentum cannot break**. Sprint,
> vault, dash, slide, and slash to the precise beat of a high-energy
> soundtrack to fuel the power of a mystical crystal core and escape a
> ruthless empire.

### The Core Pillars
*   **The World is the Beat:** There is no traditional "rhythm highway."
    The scrolling physical world *is* your timeline[cite: 1]. Obstacles
    approach you from the right, and you must execute the correct martial
    maneuver exactly as they reach you on the beat[cite: 1].
*   **Absolute Chronological Sync:** The forward momentum of the game never
    pauses, desyncs, or slows down. Mistimed inputs or failures never knock
    the player back or interrupt the music track; instead, the rhythm
    falters but the run continues.
*   **Agnostic Asset Pipeline:** The game is structured so that level
    visuals are defined strictly by unlocked "visual skins" (Biomes)[cite:
    1]. This allows the developer to swap, expand, or introduce brand-new
    parallax backgrounds without altering the underlying rhythm-collision
    logic[cite: 1].

---

## 2. Universe & Narrative Arc

> **Setting is a reskinnable content layer, not design.** The specific
> antagonists (orcs, cultists, or otherwise) and the biome names are art that
> can be swapped without touching the design. The design-relevant kernel is
> constant: an **evil empire**, an enslaved protagonist, a **non-recoverable
> kinetic charge** that powers the escape, and a **time-loop** in which perfect
> mastery makes the hero become the empire's own founder. That loop is the only
> narrative element that is mechanical — it is the reason the game has two
> endings (see §6).

### Story Synopsis
You are an enslaved female prisoner sprinting for survival through a
colossal, shifting scrap-graveyard ruled by the brutal **Iron
Empire**—an engineered warrior race of Orcs that overthrew their creators
centuries ago[cite: 1]. To escape, you must reach an ancient, hidden
Monolith[cite: 1]. Your only hope is a stolen, pure **Geima Core** in your
pack that absorbs kinetic energy to charge its latent magic. Only by
running, vaulting, sliding, and fighting in perfect rhythmic sync can you
charge the device to tear open a portal to safety[cite: 1].

The ultimate truth lies at the journey's end. Players who merely survive
will teleport to a peaceful new world to live in quiet freedom[cite: 1].
However, those who master every track in absolute rhythmic harmony will
overload the Monolith, tearing a rift through time itself[cite: 1]. They
will wake up in a prehistoric age, eventually becoming the mythical **First
Sage** who founded the very Empire that would one day enslave their
descendants—trapping them in a perfect, tragic time loop[cite: 1].

### The Backstory
Centuries ago, the **Elders**—a high-magic elven/human ruling council—lived
in a golden, peaceful empire[cite: 1]. Their utopia was entirely powered by
**Geima**, a highly volatile, humming magical crystal harvested from the
deepest, most unstable mountain veins[cite: 1]. Because the mines were toxic
and prone to rhythmic seismic collapses, the Elders used forbidden magic to
forge a brand-new, resilient worker race: the **Orcs**[cite: 1].

The Orcs were sent into the dark, brutal depths of the earth[cite: 1]. The
harsh, toxic mines and the constant tribal fighting in the dark forged them
into a hardened, powerful warrior race—slaves who deeply hated their soft
creators[cite: 1].

A member of the Elder Council, bored of a world with no wars, no conflict,
and absolute peace, secretly contacted the Orc clans[cite: 1]. He gave them
weapons, taught them how to forge iron armor, and united them into a single,
unstoppable legion[cite: 1]. The Orc Legion erupted from the mines,
conquered the soft utopia, executed the Elders, and established a brutal,
sprawling **Iron Empire**[cite: 1].

You are a descendant of those disgraced Elders, enslaved in a massive
**Graveyard Quarry**[cite: 1]. This is a colossal, shifting canyon where
slaves are forced to sift through the scrap metal and shattered stone of
conquered castles to rebuild the Empire's massive wooden siege towers[cite:
1]. Deep in a hidden cave within the quarry, your family has spent
generations secretly assembling a forbidden magical monolith using scraps of
stolen Geima-stone and forgotten Elder alchemy[cite: 1]. The game begins as
your hideout is breached[cite: 1].

---

## 3. Story Storyboard Screens

The story is told using clean, comic-book-style **static storyboard slides**
with multi-panel illustrations and captions — not animated cinematics. They are
reachable from the **Story** menu (see §6) and also play once, automatically, at
the moment their trigger is met.

> **Status: designed, not yet built.** The intro and both endings below are
> specified here but not implemented; the art resources for them do not exist
> yet.

### Screen 1: The Legacy of the Sage (Intro - Part 1)

| PANEL 1.1 | PANEL 1.2 | PANEL 1.3 |
| :---: | :---: | :---: |
| The First Sage's Portrait | The Slave Mines Revolt | The Ruins of Utopia |

*   **Panel 1.1 (The First Sage's Legacy):** A magnificent portrait of the
    legendary **First Sage**—an old, wise woman with glowing blue
    Geima-stone veins on her hands, holding a staff of white stone[cite: 1].
    Behind her, a gleaming, utopian fantasy empire rises[cite: 1].
    *   *Caption:* *"Centuries ago, the legendary First Sage discovered the
        power of the Geima-stone, building a golden utopia of peace and
        magic..."*[cite: 1]
*   **Panel 1.2 (The Iron Revolt):** The scene shifts to a dark, jagged
    quarry[cite: 1]. Orcs with pickaxes look up from the deep pits with
    glowing, furious red eyes[cite: 1]. In the foreground, a shadowy,
    corrupt Elder secretly hands them iron weapons[cite: 1].
    *   *Caption:* *"To harvest the stone, the Elders forged a warrior race
        of Orcs to slave in the toxic deep. But a bored, power-hungry
        councilman betrayed his own kin, uniting the slaves..."*[cite: 1]
*   **Panel 1.3 (The New Reign):** A burning city[cite: 1]. The white stone
    towers are crumbling, replaced by dark, soot-belching iron siege
    engines[cite: 1]. Massive Orc banners drape over the ruins[cite: 1]. Our
    main character, wearing tattered prisoner rags, is shown in chains
    sifting through scrap metal[cite: 1].
    *   *Caption:* *"The Iron Empire arose. We became the slaves, forced to
        rebuild their war machine from the scrap of our fallen
        paradise."*[cite: 1]

---

### Screen 2: The Catalyst (Intro - Part 2)

| PANEL 2.1 | PANEL 2.2 | PANEL 2.3 |
| :---: | :---: | :---: |
| The Hidden Monolith | The Quarry Raid | The Escape Run |

*   **Panel 2.1 (The Hidden Core):** Deep inside a dark, forbidden cave
    behind the quarry, our character's family works in secret around a
    massive, cracked stone archway (The Monolith)[cite: 1]. The character's
    father is holding a glowing, pulsating blue crystal—the **Geima Core**.
    *   *Caption:* *"For three generations, our family secretly repaired an
        ancient Gate of the Sages. To power it, we stole tiny fragments of
        Geima-stone to forge a master Core."*[cite: 1]
*   **Panel 2.2 (The Raid):** Red torchlight floods the cave[cite: 1]. The
    heavy silhouettes of armored Orc guards break through the wooden
    barricades[cite: 1]. Her father desperately pushes the glowing crystal
    core into our hero's hands, pointing toward the quarry exit.
    *   *Caption:* *"They found us. My father shoved the Core into my hands.
        'Run!' he cried. 'Feed the Core the rhythm of your stride! It is our
        only hope!'"*[cite: 1]
*   **Panel 2.3 (The Chase Begins):** Our hero leaps out of the cave,
    sprinting directly into the scrolling quarry background[cite: 1]. The
    core in their pack glows bright blue, pulsing in sync with the first beat
    of the music.
    *   *Caption:* *"Do not stop. Do not break the cadence. Run!"*[cite: 1]

---

### Screen 3: The Sanctuary (Escape Ending)
*Unlocks once every song has been escaped — cleared at least once, on any
difficulty, at any rank (see §6).*

| PANEL 3.1 | PANEL 3.2 | PANEL 3.3 |
| :---: | :---: | :---: |
| The Leap into Light | Waking on the Shore | A New Dawn |

*   **Panel 3.1 (The Leap):** Our hero, running at full speed, leaps with
    the glowing core held high, diving directly into the swirling blue energy
    vortex of the Monolith as Orc spears fly past.
    *   *Caption:* *"With a final, desperate stride, I plunged into the heart
        of the ancient Gate..."*[cite: 1]
*   **Panel 3.2 (The Reconstruction):** The screen fades in from white[cite:
    1]. Our hero collapses onto the soft, green grass of a beautiful,
    pristine beach[cite: 1]. Behind them, the stone Monolith violently cracks
    and shatters into pieces, permanently closing the portal[cite: 1].
    *   *Caption:* *"The Gate shattered behind us, forever sealing the Iron
        Empire away in our past. We had escaped to a new world."*[cite: 1]
*   **Panel 3.3 (A New Dawn):** The hero stands on a cliffside overlooking a
    beautiful, lush valley where her friends and loved ones are already
    starting to build a modest wooden village[cite: 1]. The sun rises over a
    free land[cite: 1].
    *   *Caption:* *"Here, far from their chains, we will build a quiet
        haven. We are finally free."*[cite: 1]

---

### Screen 4: The Overload (Master Ending - Part 1)
*Secret ending. Unlocks ONLY when the player has mastered every song — an
S-Rank on all three difficulties of every track in the game (see §6).*

| PANEL 4.1 | PANEL 4.2 | PANEL 4.3 |
| :---: | :---: | :---: |
| The Harmonic Overload | Time Reversing | Prehistoric Plain |

*   **Panel 4.1 (The Flawless Chord):** As our hero leaps into the Monolith,
    the core doesn't just glow—it explodes with a blinding white-blue light.
    The absolute harmonic precision of her perfect run has pushed the machine
    past its physical limits[cite: 1].
    *   *Caption:* *"A perfect run. A perfect rhythm. The Geima Core did not
        just activate—it resonated in absolute, flawless harmony."*
*   **Panel 4.2 (The Reverse Warp):** The background scrolls backward at
    impossible speeds[cite: 1]. We see the ruined castles of the Orcs rapidly
    "un-building" themselves back into pristine white stone towers, and then
    those towers turning back into wild, ancient forests in a dizzying blur
    of light[cite: 1].
    *   *Caption:* *"The energy ripped a hole not through space, but through
        the fabric of time itself, dragging me back through centuries of
        history..."*[cite: 1]
*   **Panel 4.3 (The New Dawn of Old):** The hero wakes up on a pristine,
    ancient plain[cite: 1]. The sky is filled with a double moon[cite: 1].
    There are no ruins, no wars, and no empires[cite: 1]. They are completely
    alone in a prehistoric wilderness[cite: 1].
    *   *Caption:* *"I awoke in an untamed, ancient age. A time before the
        Empire. A time before the Elders."*[cite: 1]

---

### Screen 5: The Eternal Loop (Master Ending - Part 2)

| PANEL 5.1 | PANEL 5.2 | PANEL 5.3 |
| :---: | :---: | :---: |
| Founding the Empire | Deathbed of the Sage | The Name Revealed |

*   **Panel 5.1 (The Founder):** Decades have passed[cite: 1]. A much older,
    wiser version of our hero is shown standing before primitive tribes[cite:
    1]. She is teaching them how to harvest a glowing blue crystal from the
    ground and build beautiful, white stone structures[cite: 1]. She holds
    the exact white stone staff seen in Panel 1.1[cite: 1].
    *   *Caption:* *"To survive, I gathered the lost tribes. I taught them
        the secrets of the Geima-stone, guiding them to build a peaceful,
        rhythmic utopia..."*[cite: 1]
*   **Panel 5.2 (The Last Breath):** The hero is now an incredibly old,
    grey-haired woman lying on a bed of silk[cite: 1]. A massive crowd of
    citizens and council members surround her, weeping[cite: 1]. One of them
    holds a crown of white stone[cite: 1].
    *   *Caption:* *"On my deathbed, as the lights of our great new empire
        shined outside my window, my people gathered to bid me
        farewell..."*[cite: 1]
*   **Panel 5.3 (The True Identity):** A close-up of our dying hero's eyes
    fading[cite: 1]. One of the grieving citizens whispers a final prayer,
    calling her by the legendary name of the **First Sage**—the exact
    ancestor whose empire would one day enslave her descendants[cite: 1].
    *   *Caption:* *"As my eyes closed, they whispered the name of the
        legendary First Sage. The loop was complete. I ran from my chains...
        only to forge them myself."*[cite: 1]

---

## 4. Gameplay & Controls

### The Kinetic Charger Loop
To power the escape gate (The Monolith) at the end of the run, the player
must charge the Geima Core in her pack[cite: 1]. The core absorbs kinetic
energy and vibration[cite: 1]. The rhythmic, steady impact of your boots
hitting the ground at high speeds, the clashing of your sword strikes, and
swift maneuvering are what actually charge the core.

If you hit minor hazards, the rhythmic charge drops, the energy bleeds out,
and your health bar depletes[cite: 1].

### Controller Mapping & Hazard Interaction Matrix
The player's character is positioned on the left-center of the screen[cite:
1]. Obstacles are strictly categorized into **Fatal Threats** (which trigger
an instant time fracture) and **Casual Obstacles** (which cause minor damage
but break apart, allowing forward momentum to continue).

When an obstacle reaches the player's physical coordinates on a beat, they
must press the matching button[cite: 1].

Every action is a direction, and all input devices agree positionally: the
keyboard arrow key, the d-pad direction, and the face button sitting in that
same position on the pad (up = Y, right = B, down = A, left = X on an Xbox
layout) all trigger the same action.

| Direction | Buttons | Combat Action | Target Hazard | Success Outcome | Failure Outcome |
| :---: | :---: | :--- | :--- | :--- | :--- |
| **Right** | **B / D-pad Right / →** | **Sword Slash** | Normal Orc Scout | Slices the weak Orc cleanly on the beat; enemy vanishes in a particle explosion. | **Fatal Failure:** You slam head-on into their weapon. The run ends in defeat. |
| **Left** | **X / D-pad Left / ←** | **Dash** | Heavy Orc Vanguard | You explosively push back the unstoppable big ogre, clearing the lane. | **Fatal Failure:** You are crushed by the heavy obstacle. The run ends in defeat. |
| **Up** | **Y / D-pad Up / ↑** | **Jump / Vault** | Gaps / Fire Barrels | You vault over the hazard in a tight aerial arc. (Not high enough to jump over enemies). | **Casual Hurt:** You fall or smash into the hazard, losing health but keeping momentum. |
| **Down** | **A / D-pad Down / ↓** | **Slide** | Barbed Wire / Beams | A quick, frictionless slide to go under low hazards like wires. | **Casual Hurt:** You strike the obstacle. You lose health but keep running. |

---

## 5. Core Mechanics & Systems

### Rhythmic Performance & The Two-Tiered Fail States
Instead of separate health and scoring meters, your health bar is your
rhythmic execution buffer[cite: 1]. **Health is non-recoverable.** To reach
the Monolith with a full health bar, you must perform a flawless rhythmic
run[cite: 1].

*   **Successful Action:** Bypasses the threat safely[cite: 1]. Your health
    bar remains untouched. Reaching the finish with a full bar is what earns
    the S-Rank (see §6).
*   **Casual Failure (Missed Jump/Dash):** The obstacle physically breaks or
    your feet clear it late. The character plays a quick "hurt/wince" pose,
    the sprite flashes red, and your health bar permanently drops by a
    chunk[cite: 1]. Forward movement and music continue seamlessly.
*   **Fatal Failure (Missed Slash/Crashing a Heavy Orc):** The character
    collides head-on with an unstoppable force. The screen violently cracks,
    the music screeches to a dead halt, and the run ends in absolute defeat,
    forcing a full level restart.

### Dynamic Tempo Scaling
The game's running speed is directly tied to the song's tempo (BPM)[cite: 1].
*   **Slow Tracks (80-100 BPM):** The environment scrolls gently; the
    character's running animation bounces lazily to the beat[cite: 1].
*   **Fast Tracks (140-170 BPM):** The background blurs, obstacles rush
    toward you at high speed, and the running animation is a frantic
    sprint[cite: 1].
*   **The Sync:** Obstacles scroll at a fixed speed (currently 250 px/s), so
    every obstacle is visible for the same warning time (~1.7 s at the 640 px
    design resolution) regardless of tempo. Faster songs feel harder because
    notes are packed closer together in time, not because obstacles move
    faster. See the [Beatmap Generation Pipeline](beatmap-generation.md) for
    how this warning time drives the map's lead-in.

---

## 6. World Structure & Progression

Rather than static, hard-coded stages, the world is designed around
**swappable environments (Zones/Biomes)**[cite: 1]. These environments are
mechanically identical but visually distinct, built to adapt to whatever
modular pixel art assets (such as forest, desert, or volcanic parallax
packs) are acquired during development[cite: 1].

### Song Selection (Fully Open)
There is no path and no forced order. Every song is available from the start;
the player picks whatever they please. Songs are grouped under Zones for visual
variety, and each song's **BPM is its difficulty signal** — a higher-BPM track
packs its notes closer together and plays harder. Players self-select challenge
by reading the BPM, not by unlocking a route.

The song count is aspirational and grows as tracks are produced; the objective
board (below) scales to whatever songs exist.

### Difficulty Selection
Independently of song choice, each song can be played on **Easy, Normal, or
Hard**. The difficulty selects which beatmap chart loads (sparser to denser).
Rank and medal records are kept per song *per difficulty*, which is what makes
mastery (below) a three-difficulty goal.

### Onboarding Sequence (Zone 1 Tutorial Layout)
> **Status: designed, not yet built.**

To introduce the mechanics seamlessly without text-heavy manual
interruptions, the initial area utilizes a forced narrative script:
1.  **The Slash Tutorial:** A lone Normal Orc approaches with a prominent
    button prompt. The player presses **Slash**, exploding the enemy and
    establishing basic rhythmic timing.
2.  **The Unstoppable Wall:** Immediately after, an armored Heavy Orc blocks
    the entire lane. The player intuitively presses **Slash** again; the
    blade bounces off harmlessly, the screen cracks, and the stage ends,
    establishing that some threats are fatal and cannot be fought.
3.  **The Retry:** The player restarts the sequence, now aware of the danger.
4.  **The Alternate Action:** As the Heavy Orc approaches again, a flashing
    prompt guides the player to use **Dash**, violently pushing the
    unstoppable ogre back and clearing the tutorial track cleanly.

### Rank Medals
This is a pure-rhythm game: there is **no score and no multiplier**. The only
measure of a run is the health remaining at the finish line, which awards a
rank medal for that song *on that difficulty*:

*   **B-Rank:** Finished with a partially depleted health bar.
*   **A-Rank:** Finished with nearly full health (≥ 50%).
*   **S-Rank:** Finished with a 100% full health bar — a flawless run.

Ranks only ever improve: a better run overwrites a worse record for that song
and difficulty. These medals are the raw material the objective board is built
on.

### The Objective Board & Two Endings
The game has two win-states, revealed one at a time so the player always sees a
reachable goal before the harder one is disclosed.

*   **Escape (the reachable ending):** a song is *escaped* the moment it is
    cleared once — any rank, any difficulty. Escape **every** song to trigger
    the Escape ending. Everyone who finishes the game sees this.
*   **Master (the secret ending):** a song is *mastered* when it holds an
    **S-Rank on all three difficulties**. Master **every** song to trigger the
    secret ending. This is the completionist's mountain.

Both endings play once, automatically, at the moment the final qualifying
medal is recorded, and are re-viewable afterward from the **Story** menu.

#### The Four-State Model
Progress — on a single song, and on the game as a whole — is always one of four
states, read the same way at every scale:

1.  **Escaping** — not yet escaped.
2.  **Escaped** — survived, but no mastery yet.
3.  **Mastering** — mastery under way.
4.  **Mastered** — fully mastered.

A **song** takes its state from its three difficulty records: escaped the moment
*any* difficulty is cleared, mastering as soon as *any* difficulty is S-ranked,
mastered when *all three* are. So escape is binary for a song — one clear is
enough — while mastery is a progression that needs the full set.

The **whole game** takes its state the same way, one level up, from its songs:
escaping until every song is escaped, mastering the moment any song is mastered,
mastered when all are. With one deliberate twist — **the game has no "escaped"
resting state.** The instant every song is escaped it rolls straight into
*mastering*. A player who escaped everything and saw "Escaped" would assume the
game was over; flipping immediately to mastering is how the secret objective
reveals itself.

#### Reading the Board
The player learns all of this by playing, with no tutorial text:

*   **Each song row** names its state. Because escape is binary, an escaped song
    just reads `ESCAPED`; because mastery is a progression, a mastering song
    shows how far along it is — how many of its three difficulties are S-ranked.
*   **The header** (the whole-game readout) pins a count onto whichever
    objective is active, to pull the player toward it: songs escaped while
    escaping, songs mastered while mastering — the same shape as a row, one
    scale up.
*   **Color** separates the four at a glance: escaping is dim, escaped is green,
    mastering is bronze, mastered is gold.
*   **The three difficulty buttons** of the selected song hold the
    per-difficulty truth — which difficulties are S-ranked. Three slots side by
    side, and the empty ones are the ask; that is what teaches "mastery = S on
    all three."

The same roll-up describes a **zone**: a biome is escaped when all its songs
are, and mastered when all its songs are, so a zone's preview can carry its own
aggregate state.

### The Story Menu
The main menu carries a **Story** entry that lets the player watch the
storyboard slides (§3) on demand. It holds three items:

*   **Intro** — always available.
*   **Escape** — greyed out until the Escape ending is unlocked.
*   **Secret** — greyed out until the Master ending is unlocked.

The locked items are shown greyed rather than hidden, so the player can *see*
that an ending exists to be earned, and that a second, secret one lies beyond
it — the objective board and this menu reinforce the same two goals.

---

## 7. Visual Art & Animation Specs

The game utilizes a classic, crisp 2D pixel art style[cite: 1]. The
characters are built using a modular sprite template to support clean
animation states[cite: 1].

### Environment & Camera Layout
*   **Viewpoint:** Side-scrolling 2D perspective[cite: 1]. The camera is
    locked on the player, while the background uses a multiple-layer parallax
    effect (Far, Mid, and Foreground) to create an illusion of infinite
    depth[cite: 1].

### Character Animation States (Asset Creation Specs)
To bring the runner to life, the player sprite assets must support six core
animation states:
1.  **The Running Loop:** A constant, energetic forward sprint[cite: 1]. The
    animation frame rate scales dynamically to bounce in sync with the song's
    BPM[cite: 1].
2.  **The Sword Slash:** A rapid, wide horizontal blade swing that snaps
    instantly when the attack button is pressed and transitions smoothly back
    to running[cite: 1].
3.  **The Jump / Airborne Frame:** A tucked, agile mid-air pose used while
    the character is physically arching through the air to clear
    barrels[cite: 1].
4.  **The Dash:** A high-speed, forceful forward burst used to violently push
    back large, unstoppable enemies.
5.  **The Slide:** A low-profile, compressed forward slide to go under
    low-hanging threats like wires.
6.  **The Hurt / Flicker State:** A brief, off-balance animation frame
    triggered when taking damage from casual obstacles, visually signaling a
    missed beat while continuing forward momentum[cite: 1].
7.  **The Crash / Defeat:** A full physical collapse frame triggered when
    striking a fatal threat, ending the run.
