import argparse
import json
import math
import os
import random
import sys

import librosa
import numpy as np

# Hard floor for the gap between actions: every action animation lasts 0.35s
# (see hero.tscn) plus a small input-safety margin.
ANIMATION_DURATION = 0.35
MIN_ACTION_GAP = 0.40

# Difficulty controls note density in two ways: the comfort buffer added on top
# of the animation duration, and how prominent a beat must be (percentile of
# per-beat onset strength) to receive an action.
DIFFICULTIES = {
    "easy": {"buffer": 0.50, "strength_percentile": 60},
    "normal": {"buffer": 0.15, "strength_percentile": 40},
    "hard": {"buffer": 0.05, "strength_percentile": 25},
}

# Game layout defaults, must match the Godot project: design resolution width
# (project.godot viewport_width, camera centered at origin), hero X position
# (game.tscn) and track scroll speed (track.gd).
VIEWPORT_WIDTH = 640.0
HERO_X = -100.0
SCROLL_SPEED = 250.0

# Mel-band split (n_mels=128) used to map sounds to actions:
# low ~ kick, mid ~ snare/toms, high ~ hats/cymbals.
BAND_CHANNELS = [0, 16, 64, 128]
DOMINANCE_RATIO = 1.25


def pick_action(band_values, last_action, rng):
    # When one band clearly dominates, the action follows the sound so the
    # choreography matches what the player hears. Ambiguous beats fall back to
    # a weighted random pick, slash being the default attack.
    low, mid, high = band_values
    ranked = sorted([(low, "low"), (mid, "mid"), (high, "high")], reverse=True)
    dominant = ranked[0][1] if ranked[0][0] >= ranked[1][0] * DOMINANCE_RATIO else None

    if dominant == "low":
        action = "slash"
    elif dominant == "mid":
        action = "jump_up"
    elif dominant == "high":
        action = rng.choice(["slide", "dash"])
    else:
        action = rng.choice(["slash", "slash", "slide", "dash", "jump_up"])

    # Rule: no double jumps.
    if action == "jump_up" and last_action == "jump_up":
        action = rng.choice(["slash", "slide", "dash"])
    return action


def generate_beatmap(audio_path, output_path, difficulty, seed,
                     viewport_width, hero_x, scroll_speed):
    settings = DIFFICULTIES[difficulty]
    min_gap = max(ANIMATION_DURATION + settings["buffer"], MIN_ACTION_GAP)
    rng = random.Random(seed)

    # An obstacle spawns at the right screen edge (viewport_width / 2 with the
    # camera at the origin) and travels to the hero. The first note must not
    # arrive before the player has seen it approach for that full distance.
    lead_time = (viewport_width / 2.0 - hero_x) / scroll_speed

    print(f"Loading audio: {audio_path}")
    y, sr = librosa.load(audio_path, sr=None)

    print("Isolating percussive track (HPSS)...")
    _, y_percussive = librosa.effects.hpss(y, margin=3.0)

    print("Tracking tempo and beat grid...")
    onset_env = librosa.onset.onset_strength(y=y_percussive, sr=sr)
    tempo, beat_frames = librosa.beat.beat_track(
        onset_envelope=onset_env, sr=sr, trim=False
    )
    tempo = float(np.atleast_1d(tempo)[0])
    beat_times = librosa.frames_to_time(beat_frames, sr=sr)

    if len(beat_frames) == 0:
        print("Error: no beats detected in this song.")
        sys.exit(1)

    print(f"Tempo: {tempo:.1f} BPM, {len(beat_frames)} beats on the grid.")

    print("Computing per-band onset strength (kick / snare / hats)...")
    band_envs = librosa.onset.onset_strength_multi(
        y=y_percussive, sr=sr, channels=BAND_CHANNELS
    )
    band_envs = band_envs / (band_envs.max(axis=1, keepdims=True) + 1e-9)

    # Strength of each beat: peak of the onset envelope around the beat frame.
    def window_max(env, frame):
        lo = max(frame - 1, 0)
        return float(env[lo:frame + 2].max())

    beat_strengths = np.array([window_max(onset_env, f) for f in beat_frames])
    threshold = np.percentile(beat_strengths, settings["strength_percentile"])

    skipped_intro = int(np.count_nonzero(beat_times < lead_time))
    print(
        f"Lead-in: {lead_time:.2f}s (screen travel), skipping {skipped_intro} "
        f"intro beat(s). Min gap: {min_gap:.2f}s ({difficulty})."
    )

    actions_list = []
    last_time = -min_gap
    last_action = ""

    for frame, time, strength in zip(beat_frames, beat_times, beat_strengths):
        if time < lead_time:
            continue
        if time - last_time < min_gap:
            continue
        if strength < threshold:
            continue

        band_values = [window_max(env, frame) for env in band_envs]
        action = pick_action(band_values, last_action, rng)

        actions_list.append({"time": float(time), "type": action})
        last_time = time
        last_action = action

    print(f"Kept {len(actions_list)} of {len(beat_frames)} beats.")

    beatmap_data = {
        "song": os.path.basename(audio_path),
        "tempo": round(tempo, 1),
        "difficulty": difficulty,
        "actions": actions_list,
    }

    with open(output_path, "w") as f:
        json.dump(beatmap_data, f, indent=2)

    print(f"Beatmap successfully saved to {output_path}")


def main():
    parser = argparse.ArgumentParser(description="Generate a beatmap JSON from a song.")
    parser.add_argument("audio_file", help="Path to the audio file")
    parser.add_argument("--difficulty", choices=DIFFICULTIES, default="normal")
    parser.add_argument("--seed", type=int, default=0,
                        help="Random seed, same seed gives the same map")
    parser.add_argument("--viewport-width", type=float, default=VIEWPORT_WIDTH,
                        help="Game design resolution width in pixels")
    parser.add_argument("--hero-x", type=float, default=HERO_X,
                        help="Hero X position relative to the camera center")
    parser.add_argument("--scroll-speed", type=float, default=SCROLL_SPEED,
                        help="Track scroll speed in pixels per second")
    args = parser.parse_args()

    if not os.path.exists(args.audio_file):
        print(f"Error: File not found: {args.audio_file}")
        sys.exit(1)

    output_file = os.path.splitext(args.audio_file)[0] + ".json"
    generate_beatmap(
        args.audio_file, output_file, args.difficulty, args.seed,
        args.viewport_width, args.hero_x, args.scroll_speed,
    )


if __name__ == "__main__":
    main()
