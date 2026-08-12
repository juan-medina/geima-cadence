import argparse
import json
import math
import os
import random
import sys

import librosa
import numpy as np

# 0.35s = action animation length in hero.tscn.
ANIMATION_DURATION = 0.35
MIN_ACTION_GAP = 0.40

# buffer: seconds added on top of ANIMATION_DURATION. strength_percentile: local
# onset-strength percentile a beat must clear to earn an action.
DIFFICULTIES = {
    "easy": {"buffer": 0.50, "strength_percentile": 25, "intro": 7.0},
    "normal": {"buffer": 0.15, "strength_percentile": 25, "intro": 5.0},
    "hard": {"buffer": 0.05, "strength_percentile": 25, "intro": 3.5},
}

# Mel-band split (n_mels=128) used to map sounds to actions:
# low ~ kick, mid ~ snare/toms, high ~ hats/cymbals.
BAND_CHANNELS = [0, 16, 64, 128]
DOMINANCE_RATIO = 1.25
BAND_ACTIONS = {"low": ["slash"], "mid": ["jump_up"], "high": ["slide", "dash"]}

# Playable actions. "sync" is the intro metronome marker, not an input, so it
# is excluded here.
ACTION_TYPES = ("slash", "jump_up", "slide", "dash")

# Cap on identical actions in a row.
MAX_ACTION_RUN = 3

# Beat strength is judged within a local +/-window of beats, not globally.
LOCAL_WINDOW_BEATS = 8

# Max grid-beats of idle before a gap gets back-filled.
MAX_GAP_BEATS = 4


def pick_action(band_values, last_action, run_length, rng):
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

    if action == "jump_up" and last_action == "jump_up":
        action = rng.choice(["slash", "slide", "dash"])

    if action == last_action and run_length >= MAX_ACTION_RUN:
        for _, band in ranked:
            candidates = [a for a in BAND_ACTIONS[band] if a != action]
            if candidates:
                action = rng.choice(candidates)
                break
    return action


def analyze_song(audio_path):
    # Difficulty-independent; computed once and shared by all three charts,
    # so the three maps line up on the same beats.
    print(f"Loading audio: {audio_path}")
    y, sr = librosa.load(audio_path, sr=None)

    print("Isolating percussive track (HPSS)...")
    _, y_percussive = librosa.effects.hpss(y, margin=3.0)

    print("Estimating tempo and detecting onsets (real hits)...")
    onset_env = librosa.onset.onset_strength(y=y_percussive, sr=sr)
    tempo, _ = librosa.beat.beat_track(onset_envelope=onset_env, sr=sr, trim=False)
    tempo = float(np.atleast_1d(tempo)[0])
    beat_frames = librosa.onset.onset_detect(
        onset_envelope=onset_env, sr=sr, backtrack=True
    )
    beat_times = librosa.frames_to_time(beat_frames, sr=sr)

    if len(beat_frames) == 0:
        print("Error: no onsets detected in this song.")
        sys.exit(1)

    print(f"Tempo: {tempo:.1f} BPM, {len(beat_frames)} onsets detected.")

    print("Computing per-band onset strength (kick / snare / hats)...")
    band_envs = librosa.onset.onset_strength_multi(
        y=y_percussive, sr=sr, channels=BAND_CHANNELS
    )
    band_envs = band_envs / (band_envs.max(axis=1, keepdims=True) + 1e-9)

    def window_max(env, frame):
        lo = max(frame - 1, 0)
        return float(env[lo:frame + 2].max())

    beat_strengths = np.array([window_max(onset_env, f) for f in beat_frames])
    band_values = [
        [window_max(env, f) for env in band_envs] for f in beat_frames
    ]

    duration = librosa.get_duration(y=y, sr=sr)

    return {
        "tempo": tempo,
        "beat_times": beat_times,
        "beat_strengths": beat_strengths,
        "band_values": band_values,
        "duration": duration,
    }


def choreograph(analysis, difficulty, seed, max_gap=None, outro_time=4.0):
    # Selects one difficulty's actions from the shared beat grid.
    settings = DIFFICULTIES[difficulty]
    lead_time = settings["intro"]
    min_gap = max(ANIMATION_DURATION + settings["buffer"], MIN_ACTION_GAP)
    rng = random.Random(seed)

    beat_times = analysis["beat_times"]
    beat_strengths = analysis["beat_strengths"]
    duration = analysis["duration"]
    end_time = duration - outro_time

    thresholds = np.array([
        np.percentile(
            beat_strengths[max(i - LOCAL_WINDOW_BEATS, 0):i + LOCAL_WINDOW_BEATS + 1],
            settings["strength_percentile"],
        )
        for i in range(len(beat_strengths))
    ])

    if max_gap is None:
        max_gap = max(MAX_GAP_BEATS * 60.0 / analysis["tempo"], 2.0 * min_gap)

    selected = []
    last_time = -min_gap

    for i, (time, strength) in enumerate(zip(beat_times, beat_strengths)):
        if time > end_time:
            continue
        if time - last_time < min_gap:
            continue
        if strength < thresholds[i]:
            continue
        selected.append(i)
        last_time = time

    # Fill any gap wider than max_gap with the strongest interior beat that
    # keeps min_gap clearance on both sides.
    filled = 0
    changed = True
    while changed:
        changed = False
        additions = []
        for a, b in zip(selected, selected[1:]):
            t0, t1 = beat_times[a], beat_times[b]
            if t1 - t0 <= max_gap:
                continue
            candidates = [
                i for i in range(a + 1, b)
                if beat_times[i] - t0 >= min_gap and t1 - beat_times[i] >= min_gap
            ]
            if not candidates:
                continue
            additions.append(max(candidates, key=lambda i: beat_strengths[i]))
            changed = True
        if additions:
            selected = sorted(set(selected) | set(additions))
            filled += len(additions)

    actions_list = []
    last_action = ""
    run_length = 0

    for i in selected:
        if beat_times[i] < lead_time:
            actions_list.append({"time": float(beat_times[i]), "type": "sync"})
            continue
        action = pick_action(analysis["band_values"][i], last_action, run_length, rng)
        actions_list.append({"time": float(beat_times[i]), "type": action})
        run_length = run_length + 1 if action == last_action else 1
        last_action = action

    print(
        f"  {difficulty}: kept {len(actions_list)} of {len(beat_times)} beats "
        f"({filled} gap-filled, min gap {min_gap:.2f}s, max gap {max_gap:.2f}s)."
    )
    return actions_list


def generate_beatmap(audio_path, output_path, seed, max_gap=None, outro_time=4.0):
    analysis = analyze_song(audio_path)

    skipped_outro = int(np.count_nonzero(analysis["beat_times"] > analysis["duration"] - outro_time))
    print(f"Outro: {outro_time:.2f}s, skipping {skipped_outro} outro beat(s).")
    print("Choreographing every difficulty:")

    difficulties = {}
    for name in DIFFICULTIES:
        actions = choreograph(analysis, name, seed, max_gap, outro_time)
        difficulties[name] = {
            "actions": actions,
        }

    beatmap_data = {
        "song": os.path.basename(audio_path),
        "tempo": round(analysis["tempo"], 1),
        "difficulties": difficulties,
    }

    with open(output_path, "w") as f:
        json.dump(beatmap_data, f, indent=2)

    print(f"Beatmap successfully saved to {output_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Generate a beatmap JSON (all difficulties) from a song."
    )
    parser.add_argument("audio_file", help="Path to the audio file")
    parser.add_argument("--seed", type=int, default=0,
                        help="Random seed, same seed gives the same map")
    parser.add_argument("--max-gap", type=float, default=None,
                        help="Maximum silence between notes in seconds "
                             "(default: 4 beats at the detected tempo)")
    parser.add_argument("--outro-time", type=float, default=6.0,
                        help="Seconds of empty track to leave at the end of the song")
    args = parser.parse_args()

    if not os.path.exists(args.audio_file):
        print(f"Error: File not found: {args.audio_file}")
        sys.exit(1)

    song_name = os.path.splitext(os.path.basename(args.audio_file))[0]
    output_file = os.path.join("assets", "songs", song_name + ".json")
    generate_beatmap(
        args.audio_file, output_file, args.seed, args.max_gap, args.outro_time
    )


if __name__ == "__main__":
    main()
