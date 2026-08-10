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
    visuals are defined strictly by "visual skins" (Biomes)[cite:
    1]. This allows the developer to swap, expand, or introduce brand-new
    parallax backgrounds without altering the underlying rhythm-collision
    logic[cite: 1].

---

## 2. Universe & Narrative Arc

> **Setting is a reskinnable content layer, not design.** The specific
> antagonists — the shipped game uses a **cult**, but orcs or anything else would
> serve equally — and the biome names are art that can be swapped without touching
> the design. The design-relevant kernel is
> constant: an **evil empire**, an enslaved protagonist, a **non-recoverable
> kinetic charge** that powers the escape, and a **time-loop** in which perfect
> mastery makes the hero become the empire's own founder. That loop is the only
> narrative element that is mechanical — it is the reason the game has two
> endings (see §6).

### Story Synopsis
You are an enslaved female prisoner sprinting for survival through a
colossal, shifting scrap-graveyard ruled by the brutal **Iron
Empire**—an engineered warrior race, forged to toil in the deep, that
overthrew their creators centuries ago[cite: 1]. Your only hope of escape is
a stolen, pure **Geima Core** in your pack that absorbs kinetic energy to
charge its latent magic. Only by running, vaulting, sliding, and fighting in
perfect rhythmic sync can you charge the Core enough to tear open a portal to
safety[cite: 1].

The ultimate truth lies at the journey's end. Players who merely survive
will teleport to a peaceful new world to live in quiet freedom[cite: 1].
However, those who master every track in absolute rhythmic harmony will
overload the Core, tearing a rift through time itself[cite: 1]. They
will wake up in a prehistoric age, eventually becoming the mythical **First
Sage** who founded the very Empire that would one day enslave their
descendants—trapping them in a perfect, tragic time loop[cite: 1].

### The Backstory
Centuries ago, the **Elders**—a high-magic elven/human ruling council—lived
in a golden, peaceful empire[cite: 1]. Their utopia was entirely powered by
**Geima**, a highly volatile, humming magical crystal harvested from the
deepest, most unstable mountain veins[cite: 1]. Because the mines were toxic
and prone to rhythmic seismic collapses, the Elders used forbidden magic to
forge a brand-new, resilient worker race to labor in the deep[cite: 1].

The workers were sent into the dark, brutal depths of the earth[cite: 1]. The
harsh, toxic mines and the constant fighting in the dark forged them into a
hardened, powerful warrior race—slaves who deeply hated their soft
creators[cite: 1].

A member of the Elder Council, bored of a world with no wars, no conflict,
and absolute peace, secretly contacted the slaves in the deep[cite: 1]. He
gave them weapons, taught them forbidden magic, and bound them into a single,
fanatical **cult**[cite: 1]. The cult erupted from the mines, conquered the
soft utopia, executed the Elders, and established a brutal, sprawling **Iron
Empire**[cite: 1].

You are a descendant of those disgraced Elders, enslaved in a massive
**Graveyard Quarry**[cite: 1]. This is a colossal, shifting canyon where
slaves are forced to sift through the scrap metal and shattered stone of
conquered castles to rebuild the Empire's massive wooden siege towers[cite:
1]. Deep in a hidden cave within the quarry, your family has spent
generations secretly forging a forbidden master **Geima Core** from scraps of
stolen Geima-stone and forgotten Elder alchemy[cite: 1]. The game begins as
your hideout is breached[cite: 1].

---

## 3. Story Storyboard Screens

The story is told using clean, comic-book-style **static storyboard slides**
with multi-scene illustrations and captions — not animated cinematic. They are
reachable from the **Story** menu (see §6) and also play once, automatically, at
the moment their trigger is met.

The catalogue lives in `src/data/assets/story/story.tres` as three sequences —
**Intro**, **Escape**, and **Secret** — of two slides each (six slides total).
Each slide is a single multi-scene illustration carrying up to three captions.

> **Status: captions and playback implemented; art in production.** The slide
> text, music, and sequencing exist in `story.tres`; the panel illustrations are
> being drawn from the art brief and land as they are delivered.

### Sequence 1: Intro (always available)

*   **Slide 1.1 (The Legend & The Betrayal):** A split composition of past and
    present. On one side the dignified **First Sage** holds her white stone staff
    before the golden utopia; on the other, a corrupt councilman secretly hands
    dark magic to the cult in the quarry pit.
    *   *"Centuries ago, the legendary First Sage discovered the power of the
        Geima-stone, building a golden utopia of peace and magic."*
    *   *"To harvest the stone, the Elders forged a warrior race to slave in the
        toxic deep. But a bored, power-hungry councilman betrayed his own kin,
        uniting the slaves."*
    *   *"The Empire arose. We became the slaves, forced to rebuild their war
        machine from the scrap of our fallen paradise."*
*   **Slide 1.2 (The Raid & The Chase):** Inside the hidden cave, the father
    shoves the glowing blue **Geima Core** into the protagonist's hands as cultist
    guards smash through the wooden barricades, pointing her toward the exit.
    *   *"For three generations, my family secretly forged a master Core from
        stolen fragments of Geima-stone - the one key that could tear open a road
        to freedom."*
    *   *"They found us. My father shoved the Core into my hands. 'Run!' he cried.
        'Feed the Core the rhythm of your stride! It is our only hope!'"*
    *   *"Do not stop. Do not break the cadence. Escape!"*

---

### Sequence 2: Escape Ending
*Unlocks once every song has been escaped — cleared at least once, on any
difficulty, at any rank (see §6).*

*   **Slide 2.1 (The Portal Leap):** The protagonist dives headfirst mid-sprint
    into a swirling blue rift torn open by the Core she holds high, as cultist
    spears streak past her through the dark.
    *   *"The Core blazed in my hands, tearing the air ahead into a churning vortex
        of blue Geima light. One last stride stood between me and the end of the
        run."*
    *   *"I threw myself into the air, the Core held high, its glow searing bright
        as the rhythm of a thousand steps poured out of it at once."*
    *   *"Cultist spears tore past me through the dark. I did not look back. I
        plunged headlong into the heart of the rift the Core had torn."*
*   **Slide 2.2 (A New Dawn):** She stands tall on a grassy cliff above a peaceful
    valley where escaped villagers raise homes under a rising sun, the spent Core
    dark and cracked in her hand.
    *   *"I woke on soft grass, the roar of the run gone, replaced by the gentle
        wash of waves. In my hand the Core lay dark and cracked, its power forever
        spent."*
    *   *"The Empire was sealed away in a past that could no longer reach us. On a
        green cliff above a wide valley, my people had already begun to build."*
    *   *"Here we built a quiet haven, free at last - yet the Core still hummed, as
        if only those who master every escape, every road run unbroken, might reach
        somewhere greater."*

---

### Sequence 3: Master Ending (secret)
*Unlocks ONLY when the player has mastered every song — an S-Rank on all three
difficulties of every track in the game (see §6).*

*   **Slide 3.1 (The Overload & Displacement):** The Core detonates mid-leap in a
    flash of white and sky-blue pigment, speed-lines tearing through time into an
    ancient, untamed prehistoric plain beneath a double moon.
    *   *"A perfect run. A perfect rhythm. The Geima Core did not just activate -
        it resonated in absolute, flawless harmony."*
    *   *"The energy ripped a hole not through space, but through time itself,
        dragging me back through centuries of history."*
    *   *"I awoke in an untamed, ancient age. A time before the Empire. A time
        before the Elders."*
*   **Slide 3.2 (The Closed Loop):** The dying, grey-haired Sage lies peacefully
    among bowing citizens; as her eyes close, the faint blue Geima veins on her
    hands fade, revealing her as the exact **First Sage** from Slide 1.1.
    *   *"To survive, I gathered the lost tribes. I taught them the secrets of the
        Geima-stone, guiding them to build a peaceful, rhythmic utopia."*
    *   *"On my deathbed, as the lights of our great new empire shined outside my
        window, my people gathered to bid me farewell."*
    *   *"As my eyes closed, they whispered the name of the legendary First Sage.
        The loop was complete. I ran from my chains... only to forge them myself."*

---

## 4. Gameplay & Controls

### The Kinetic Charger Loop
To power the escape at the end of the run, the player must charge the Geima
Core in her pack[cite: 1]. The core absorbs kinetic
energy and vibration[cite: 1]. The rhythmic, steady impact of your boots
hitting the ground at high speeds, the clashing of your sword strikes, and
swift maneuvering are what actually charge the core.

If you hit minor hazard your health bar depletes[cite: 1].

### Controller Mapping & Hazard Interaction Matrix
The player's character is positioned on the left-center of the screen[cite:
1]. Every obstacle demands one matching maneuver, and a mistimed or wrong
input is never instantly fatal: the blow simply lands, costing a fixed chunk
of health while forward momentum and the music continue. A run ends only when
accumulated misses drain the health bar to empty.

When an obstacle reaches the player's physical coordinates on a beat, they
must press the matching button[cite: 1].

Every action is a direction, and all input devices agree positionally: the
keyboard arrow key, the d-pad direction, and the face button sitting in that
same position on the pad (up = Y, right = B, down = A, left = X on an Xbox
layout) all trigger the same action.

| Direction | Buttons | Combat Action | Target Hazard | Success Outcome | Failure Outcome |
| :---: | :---: | :--- | :--- | :--- | :--- |
| **Right** | **B / D-pad Right / →** | **Sword Slash** | Assassin Cultist (light scout) | Slices the assassin cleanly on the beat; the enemy vanishes in a particle explosion. | **Hurt:** their blade lands and your health drops, but you keep running; the cultist turns to watch you pass. |
| **Left** | **X / D-pad Left / ←** | **Dash** | Big Cultist (heavy brute) | You explosively shove back the unstoppable brute, clearing the lane. | **Hurt:** the brute's blow lands and your health drops, but you keep running; he turns to watch you pass. |
| **Up** | **Y / D-pad Up / ↑** | **Jump / Vault** | Shoggoth (low tentacle) | You vault over the writhing tentacle in a tight aerial arc. | **Hurt:** You clip the tentacle, losing health but keeping momentum. |
| **Down** | **A / D-pad Down / ↓** | **Slide** | Fireball | A quick, frictionless slide to duck under the hurled fireball. | **Hurt:** The fireball strikes you, losing health but keeping momentum. |

---

## 5. Core Mechanics & Systems

### Rhythmic Performance & The Fail State
Instead of separate health and scoring meters, your health bar is your
rhythmic execution buffer[cite: 1]. **Health is non-recoverable.** To reach
the finish with a full health bar, you must perform a flawless rhythmic
run[cite: 1].

*   **Successful Action:** Bypasses the threat safely[cite: 1]. Your health
    bar remains untouched. Reaching the finish with a full bar is what earns
    the S-Rank (see §6).
*   **Missed Action:** Every threat is answered the same way — a wrong or
    absent input lands a hit. The character plays a quick "hurt/wince" pose,
    the sprite flashes red, and the health bar permanently drops by a fixed
    chunk, whichever obstacle it was. Enemy threats turn to watch you run
    past; hazards break apart behind you. Forward movement and music continue
    seamlessly.
*   **Defeat:** The run ends only when accumulated misses spend the last of
    the health bar. The character collapses, the music screeches to a halt,
    and the level restarts. No single obstacle is fatal on its own — defeat is
    always the sum of missed beats.

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
    triggered when a missed beat lands a hit, visually signaling it while
    continuing forward momentum[cite: 1].
7.  **The Crash / Defeat:** A full physical collapse frame triggered when the
    last of the health bar is spent, ending the run.
