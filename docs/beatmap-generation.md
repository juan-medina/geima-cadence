# Beatmap Generation Pipeline

Beatmaps are not authored by hand. A script (`scripts/beatmap_generator.py`) listens to a song and produces a JSON file with one entry per obstacle: *when* it must reach the hero and *which* action defeats it. The game (`track.gd`) simply reads that file and places obstacles along the track.

This section explains how the script decides those two things, without requiring any audio-theory background.

## The Pipeline at a Glance

```
 song.mp3
    │
    ▼
┌──────────────────────────┐
│ 1. Split the audio       │  keep the drums, discard melody & vocals
└──────────────────────────┘
    │  drums only
    ▼
┌──────────────────────────┐
│ 2. Measure the hits      │  "how hard is something hitting right now?"
└──────────────────────────┘
    │  a spiky curve over time
    ▼
┌──────────────────────────┐
│ 3. Find the beat grid    │  the song's tempo (BPM) and tick positions
└──────────────────────────┘
    │  a list of beats
    ▼
┌──────────────────────────┐
│ 4. Pick the note beats   │  strong enough + far enough apart
└──────────────────────────┘
    │  the playable beats
    ▼
┌──────────────────────────┐
│ 5. Pick each action      │  kick → slash, snare → jump, hats → slide/dash
└──────────────────────────┘
    │
    ▼
 song.json   (the beatmap the game loads)
```

## Step 1 — Split the Audio

A song is a mix of two kinds of sound: **sustained tones** (vocals, synths, guitar chords) and **short sharp hits** (drums and percussion). Only the hits define the rhythm the player must follow, so the first step throws the tones away.

The trick: if you picture a song as an image with time going right and pitch going up, tones draw *horizontal* streaks (a note held over time) while hits draw *vertical* streaks (all pitches at once, for an instant). The separation algorithm (called HPSS) keeps only the vertical ones.

```
      full song                       drums only
pitch ▲                         pitch ▲
      │ ━━━━━━━━━  (vocals)           │    ┃     ┃    ┃
      │ ━━━━━━    (synth)             │    ┃     ┃    ┃
      │   ┃    ┃    ┃ (drums)         │    ┃     ┃    ┃
      └────────────────▶ time         └────────────────▶ time
       tones = horizontal              hits = vertical
```

## Step 2 — Measure the Hits

From the drums-only audio we compute a single curve: at every instant, *how much new sound just started?* Every drum hit produces a spike; silence and sustained noise stay flat. Tall spikes are strong hits (a kick landing), small bumps are weak ones (a ghost note, a soft hat tick).

## Step 3 — Find the Beat Grid

Spikes alone are not a rhythm — drum fills, ghost notes, and off-beat ticks would produce obstacles that feel random. What a player actually locks onto is the **pulse**: the steady tick you tap your foot to.

The beat tracker works like that foot: it tries different tempos and picks the one whose evenly-spaced grid lines up with the most (and strongest) spikes. The output is the song's BPM plus a timestamp for every tick of that grid.

```
hit energy
   █        █      █        █   ▂      █
   █    ▂   █      █        █   █      █
───┴────┴───┴──────┴────────┴───┴──────┴────▶ time
   ▲        ▲      ▲        ▲          ▲
   │        │      │        │          │       the beat grid
  beat     beat   beat     beat       beat

  the small spikes between grid lines are fills/ghost
  notes — they are IGNORED, notes only land on the grid
```

This is the core guarantee of the pipeline: **every obstacle sits on the musical grid**, which is what makes hitting them feel "locked in" with the song. It also feeds the Dynamic Tempo Scaling system, since the detected BPM is written into the beatmap.

## Step 4 — Pick Which Beats Become Obstacles

Not every grid beat should be an obstacle. Two filters run over the beat list:

1. **Strength** — each beat is scored by the height of the hit-energy spike at its position. Only beats above a difficulty-dependent cutoff get a note, so obstacles land where the music actually emphasizes.
2. **Minimum gap** — the hero's action animations take **0.35 s**, so two notes closer than that are physically unplayable. On top of that we add a small comfort buffer per difficulty.

```
beat grid:       B1     B2     B3     B4     B5     B6
strength:        9      2      8      7      1      9
strong enough?   yes    no     yes    yes    no     yes
gap check:       keep   -      keep   too    -      keep
                                      close
                 ▼             ▼                    ▼
obstacles:       ◆             ◆                    ◆
```

Note the player never needs raw reaction time: obstacles are visible on screen for ~1.7 s before they arrive (see Step 6), so they *sight-read* the track. The gap only exists so the previous animation can finish.

| Difficulty | Comfort buffer | Minimum gap | Feels like |
| :--- | :---: | :---: | :--- |
| Easy | 0.50 s | 0.85 s | a note every 2 beats |
| Normal | 0.15 s | 0.50 s | a note every beat up to 120 BPM |
| Hard | 0.05 s | 0.40 s | a note every beat up to 150 BPM |

Difficulty also raises or lowers the strength cutoff, so Easy keeps only the loudest, most obvious hits.

## Step 5 — Pick the Action for Each Obstacle

Instead of assigning actions randomly, the script listens to *what kind* of drum produced each beat. The drums-only audio is split into three frequency bands, and the loudest band at that moment picks the action — so the choreography matches what the player hears:

| What the ear hears | Band | Typical source | Action |
| :--- | :---: | :--- | :--- |
| deep "thump" | low | kick drum | **Slash** |
| sharp "crack" | mid | snare drum | **Jump** |
| bright "tss" | high | hi-hats / cymbals | **Slide** or **Dash** |
| no clear winner | — | everything at once | weighted random (slash favored) |

Two extra rules shape the result:

* **No double jumps** — a jump is never followed immediately by another jump.
* **Deterministic randomness** — the random picks use a fixed seed, so generating the same song twice produces the exact same beatmap. Patterns stay learnable because the music itself repeats: the same drum loop produces the same obstacle sequence.

## Step 6 — The Lead-in (First-Note Delay)

The start of the map is not a fixed delay — it is derived from screen geometry. Obstacles spawn at the right edge of the screen and scroll toward the hero:

```
               screen (640 px design resolution)
 ┌───────────────────────────────────────────────────┐
 │                                                   │
 │      H ◀───────────── 420 px ───────────────── ◆  │
 │    hero                                  obstacle │
 │  (x = -100)                             spawns at │
 │                                        right edge │
 └───────────────────────────────────────────────────┘
          everything scrolls left at 250 px/s

     warning time = 420 px ÷ 250 px/s = 1.68 s
```

Any beat earlier than **1.68 s** into the song would spawn an obstacle *already on screen*, giving the player less than the full warning window. So the generator simply skips the handful of grid beats that fall inside that window — typically the first one or two — and the map starts at the first beat the player can fully see coming.

Because the value is computed from the design resolution, hero position, and scroll speed, changing any of those in the game automatically changes the lead-in (the script takes them as parameters: `--viewport-width`, `--hero-x`, `--scroll-speed`).

## The Output

The result is a small JSON file next to the song, which is all the game ever reads:

```json
{
  "song": "Disco_Medusae.mp3",
  "tempo": 114.8,
  "difficulty": "normal",
  "actions": [
    { "time": 6.815, "type": "slash" },
    { "time": 7.337, "type": "slide" },
    { "time": 7.859, "type": "jump_up" }
  ]
}
```

`time` is the moment (in seconds of song playback) the obstacle must reach the hero — i.e., the moment the player presses the button. The game places each obstacle at `time × scroll speed` pixels down the track and scrolls the whole track in sync with music playback, so audio and gameplay can never drift apart.
