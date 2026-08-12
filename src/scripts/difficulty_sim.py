# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT
"""Difficulty simulator for the geima-cadence beatmaps.

Simulates every chart against a set of player archetypes to estimate how hard
each song is per difficulty and who can clear it. Health-survival model per GDD
sec. 4-5; miss damage and rank thresholds come from difficulty_table.tres.

Run from the data repo root (src/data), which owns the .venv with numpy + scipy:

    python scripts/difficulty_sim.py
    python scripts/difficulty_sim.py --runs 20000 --csv out.csv
    python scripts/difficulty_sim.py --song for_hope
"""

from __future__ import annotations

import argparse
import csv
import json
import math
import re
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from scipy.special import erf

# damage_per_hit and the S / A rank thresholds are read from difficulty_table.tres.
MAX_HEALTH: float = 100.0

# Markers, not playable inputs -- excluded from every metric.
NON_PLAYABLE_TYPES: frozenset[str] = frozenset({"sync"})

DIFFICULTY_ORDER: tuple[str, ...] = ("easy", "normal", "hard")

# Sentinel gap for the first note, which has no predecessor.
FREE_GAP_SECONDS: float = 1e9


@dataclass(frozen=True)
class Archetype:
    """A player answering an anticipated stream of obstacles.

    Obstacles are visible ~1.7s before they land, so the binding per-obstacle
    cost modeled here is motor execution, not recognition.
    """

    name: str
    cycle_mean: float  # seconds to fire the next press in a rhythm
    cycle_sd: float  # run-to-run spread of that time
    switch_cost: float  # extra seconds when the maneuver differs from the last
    fumble_rate: float  # chance of a wrong press with all the time in the world


# Starting values are informed guesses; calibrate against real runs later.
ARCHETYPES: tuple[Archetype, ...] = (
    Archetype("Pro", 0.14, 0.04, 0.05, 0.005),
    Archetype("Skilled gamer", 0.18, 0.05, 0.07, 0.010),
    Archetype("Average gamer", 0.24, 0.07, 0.09, 0.020),
    Archetype("Casual / older reflexes", 0.30, 0.09, 0.12, 0.035),
)

# The chart difficulty index (expected misses) is reported for this archetype.
REFERENCE_ARCHETYPE: str = "Average gamer"


@dataclass(frozen=True)
class Chart:
    song_id: str
    song_name: str
    difficulty: str  # easy | normal | hard
    times: np.ndarray  # playable obstacle times, seconds, ascending
    switched: np.ndarray  # bool, True when this obstacle differs from the previous
    gaps: np.ndarray  # seconds since the previous playable obstacle

    @property
    def note_count(self) -> int:
        return int(self.times.size)


@dataclass(frozen=True)
class DifficultyProfile:
    damage_per_hit: float
    s_min_health: float
    a_min_health: float


@dataclass(frozen=True)
class Outcome:
    clear_rate: float
    death_rate: float
    s_rate: float
    a_rate: float
    b_rate: float
    mean_misses: float  # simulated, uncapped -- difficulty load
    expected_misses: float  # analytic sum(p_miss) -- cross-check + difficulty index


def load_song_names(raw_songs_path: Path) -> dict[str, str]:
    """Map an .ogg basename (as stored in each chart's `song` field) to its name."""
    if not raw_songs_path.is_file():
        return {}
    data = json.loads(raw_songs_path.read_text(encoding="utf-8"))
    names: dict[str, str] = {}
    for entry in data.get("songs", []):
        output: str = entry.get("output", "")
        name: str = entry.get("name", "")
        if output and name:
            names[Path(output).name] = name
    return names


def build_chart(
    song_id: str, song_name: str, difficulty: str, actions: list[dict]
) -> Chart | None:
    """Turn a difficulty's raw action list into gap/switch arrays. None if empty."""
    playable = [a for a in actions if a.get("type") not in NON_PLAYABLE_TYPES]
    playable.sort(key=lambda a: a["time"])
    if len(playable) < 2:
        return None

    times = np.array([a["time"] for a in playable], dtype=np.float64)
    types = [a["type"] for a in playable]

    gaps = np.empty_like(times)
    gaps[0] = FREE_GAP_SECONDS
    gaps[1:] = np.diff(times)

    switched = np.zeros(times.size, dtype=bool)
    for i in range(1, len(types)):
        switched[i] = types[i] != types[i - 1]

    return Chart(song_id, song_name, difficulty, times, switched, gaps)


def miss_probabilities(chart: Chart, arch: Archetype) -> np.ndarray:
    """Per-obstacle probability of a miss for this archetype.

    required = cycle_mean + switch_cost (when the maneuver changed). p_time is the
    normal-CDF probability that required (spread cycle_sd) exceeds the gap since
    the previous obstacle; the flat fumble_rate applies on top.
    """
    required = np.full(chart.note_count, arch.cycle_mean, dtype=np.float64)
    required[chart.switched] += arch.switch_cost

    if arch.cycle_sd > 0.0:
        z = (required - chart.gaps) / (arch.cycle_sd * math.sqrt(2.0))
        p_time = 0.5 * (1.0 + erf(z))
    else:
        p_time = (required > chart.gaps).astype(np.float64)

    return arch.fumble_rate + (1.0 - arch.fumble_rate) * p_time


def simulate(
    chart: Chart, arch: Archetype, runs: int, rng: np.random.Generator, profile: DifficultyProfile
) -> Outcome:
    p_miss = miss_probabilities(chart, arch)

    draws = rng.random((runs, chart.note_count))
    total_misses = (draws < p_miss).sum(axis=1)

    health_pct = (MAX_HEALTH - total_misses * profile.damage_per_hit) / MAX_HEALTH

    dead = health_pct <= 0.0
    alive = ~dead
    s = alive & (health_pct >= profile.s_min_health)
    a = alive & ~s & (health_pct >= profile.a_min_health)
    b = alive & ~s & ~a

    return Outcome(
        clear_rate=float(np.mean(alive)),
        death_rate=float(np.mean(dead)),
        s_rate=float(np.mean(s)),
        a_rate=float(np.mean(a)),
        b_rate=float(np.mean(b)),
        mean_misses=float(np.mean(total_misses)),
        expected_misses=float(np.sum(p_miss)),
    )


def parse_difficulty_table(path: Path) -> dict[str, DifficultyProfile]:
    """Read damage_per_hit and the S / A health thresholds per difficulty from the
    Godot .tres resource the game itself loads."""
    text = path.read_text(encoding="utf-8")
    subs: dict[str, dict[str, float]] = {}
    mapping: dict[str, str] = {}
    current: dict[str, float] | None = None
    in_resource = False
    for raw in text.splitlines():
        line = raw.strip()
        if line.startswith("[sub_resource"):
            match = re.search(r'id="([^"]+)"', line)
            current = {}
            if match:
                subs[match.group(1)] = current
            in_resource = False
        elif line.startswith("[resource]"):
            current = None
            in_resource = True
        elif line.startswith("["):
            current = None
            in_resource = False
        elif "=" in line:
            key, _, value = line.partition("=")
            key = key.strip()
            value = value.strip()
            if in_resource:
                match = re.search(r'SubResource\("([^"]+)"\)', value)
                if match and key in DIFFICULTY_ORDER:
                    mapping[key] = match.group(1)
            elif current is not None and key in ("damage_per_hit", "s_min_health", "a_min_health"):
                current[key] = float(value)
    profiles: dict[str, DifficultyProfile] = {}
    for difficulty in DIFFICULTY_ORDER:
        fields = subs.get(mapping.get(difficulty, ""), {})
        profiles[difficulty] = DifficultyProfile(
            fields.get("damage_per_hit", 0.0),
            fields.get("s_min_health", 0.0),
            fields.get("a_min_health", 0.0),
        )
    return profiles


def load_charts(songs_dir: Path, names: dict[str, str], song_filter: str | None) -> list[Chart]:
    charts: list[Chart] = []
    for song_path in sorted(songs_dir.glob("*.json")):
        if song_filter and song_filter.lower() not in song_path.stem.lower():
            continue
        data = json.loads(song_path.read_text(encoding="utf-8"))
        song_id = song_path.stem
        song_name = names.get(data.get("song", ""), song_id)
        difficulties = data.get("difficulties", {})
        for difficulty in DIFFICULTY_ORDER:
            block = difficulties.get(difficulty)
            if not block:
                continue
            chart = build_chart(song_id, song_name, difficulty, block.get("actions", []))
            if chart is not None:
                charts.append(chart)
    return charts


def _pct(value: float) -> str:
    return f"{value * 100:5.1f}%"


def print_archetype_tables(results: dict[tuple[str, str, str], Outcome], charts: list[Chart]) -> None:
    song_order: list[str] = []
    name_by_id: dict[str, str] = {}
    for chart in charts:
        if chart.song_id not in name_by_id:
            name_by_id[chart.song_id] = chart.song_name
            song_order.append(chart.song_id)

    for arch in ARCHETYPES:
        print(f"\n=== {arch.name} "
              f"(cycle {arch.cycle_mean:.2f}s +/-{arch.cycle_sd:.2f}, "
              f"switch +{arch.switch_cost:.2f}s, fumble {arch.fumble_rate:.1%}) ===")
        print(f"{'Song':<22} {'Difficulty':<8}  {'Clear':>6} {'Death':>6} "
              f"{'S':>6} {'A':>6} {'B':>6} {'Misses':>7}")
        for song_id in song_order:
            for difficulty in DIFFICULTY_ORDER:
                key = (song_id, difficulty, arch.name)
                if key not in results:
                    continue
                o = results[key]
                label = name_by_id[song_id] if difficulty == DIFFICULTY_ORDER[0] else ""
                print(f"{label:<22} {difficulty:<8}  "
                      f"{_pct(o.clear_rate):>6} {_pct(o.death_rate):>6} "
                      f"{_pct(o.s_rate):>6} {_pct(o.a_rate):>6} {_pct(o.b_rate):>6} "
                      f"{o.mean_misses:7.2f}")


def print_landscape(results: dict[tuple[str, str, str], Outcome], charts: list[Chart], clear_target: float) -> None:
    """For each chart, the weakest archetype that still clears >= the target."""
    weakest_first = list(reversed(ARCHETYPES))  # casual -> pro
    print(f"\n=== Difficulty landscape "
          f"(weakest archetype clearing >= {clear_target:.0%}, and expected misses "
          f"for '{REFERENCE_ARCHETYPE}') ===")
    print(f"{'Song':<22} {'Difficulty':<8}  {'Weakest clearer':<24} {'Idx':>6}")

    seen: set[str] = set()
    for chart in charts:
        clearer = "-- nobody --"
        for arch in weakest_first:
            outcome = results.get((chart.song_id, chart.difficulty, arch.name))
            if outcome and outcome.clear_rate >= clear_target:
                clearer = arch.name
                break
        index = results.get((chart.song_id, chart.difficulty, REFERENCE_ARCHETYPE))
        idx_text = f"{index.expected_misses:6.2f}" if index else "   n/a"
        label = chart.song_name if chart.song_id not in seen else ""
        seen.add(chart.song_id)
        print(f"{label:<22} {chart.difficulty:<8}  {clearer:<24} {idx_text}")


def write_csv(path: Path, results: dict[tuple[str, str, str], Outcome], charts: list[Chart]) -> None:
    name_by_id = {c.song_id: c.song_name for c in charts}
    notes_by_key = {(c.song_id, c.difficulty): c.note_count for c in charts}
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow([
            "song_id", "song_name", "difficulty", "notes", "archetype",
            "clear_rate", "death_rate", "s_rate", "a_rate", "b_rate",
            "mean_misses", "expected_misses",
        ])
        for (song_id, difficulty, arch_name), o in results.items():
            writer.writerow([
                song_id, name_by_id.get(song_id, song_id), difficulty,
                notes_by_key.get((song_id, difficulty), 0), arch_name,
                f"{o.clear_rate:.4f}", f"{o.death_rate:.4f}", f"{o.s_rate:.4f}",
                f"{o.a_rate:.4f}", f"{o.b_rate:.4f}",
                f"{o.mean_misses:.4f}", f"{o.expected_misses:.4f}",
            ])


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Simulate beatmap difficulty per player archetype.")
    parser.add_argument("--runs", type=int, default=5000, help="Monte Carlo runs per chart/archetype.")
    parser.add_argument("--seed", type=int, default=0, help="RNG seed (deterministic).")
    parser.add_argument("--song", type=str, default=None, help="Only simulate songs whose id contains this.")
    parser.add_argument("--clear-target", type=float, default=0.90, help="Clear-rate bar for the landscape summary.")
    parser.add_argument("--csv", type=Path, default=None, help="Optional path to write full results as CSV.")
    parser.add_argument("--songs-dir", type=Path, default=Path("assets/songs"), help="Directory of chart JSON files.")
    parser.add_argument("--raw-songs", type=Path, default=Path("scripts/config/songs.json"), help="Source JSON for friendly names.")
    parser.add_argument("--difficulty-table", type=Path, default=Path("assets/difficulty/difficulty_table.tres"), help="Godot .tres with per-difficulty damage and rank thresholds.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if not args.songs_dir.is_dir():
        print(f"error: songs dir not found: {args.songs_dir.resolve()} "
              f"(run this from the data repo root, src/data)")
        return 1

    names = load_song_names(args.raw_songs)
    charts = load_charts(args.songs_dir, names, args.song)
    if not charts:
        print("error: no charts loaded (check --song filter and --songs-dir).")
        return 1

    profiles = parse_difficulty_table(args.difficulty_table)

    rng = np.random.default_rng(args.seed)
    results: dict[tuple[str, str, str], Outcome] = {}
    for chart in charts:
        for arch in ARCHETYPES:
            results[(chart.song_id, chart.difficulty, arch.name)] = simulate(
                chart, arch, args.runs, rng, profiles[chart.difficulty]
            )

    songs = len({c.song_id for c in charts})
    print(f"Simulated {len(charts)} charts across {songs} songs, "
          f"{len(ARCHETYPES)} archetypes, {args.runs} runs each.")
    print(f"Rank model from {args.difficulty_table} (health {MAX_HEALTH:.0f}):")
    for difficulty in DIFFICULTY_ORDER:
        profile = profiles[difficulty]
        dead_at = MAX_HEALTH / profile.damage_per_hit if profile.damage_per_hit > 0.0 else 0.0
        print(f"  {difficulty:<7} damage {profile.damage_per_hit:.2f}  "
              f"S>={profile.s_min_health:.0%} health  A>={profile.a_min_health:.0%} health  "
              f"dead at {dead_at:.0f} misses")

    print_archetype_tables(results, charts)
    print_landscape(results, charts, args.clear_target)

    if args.csv is not None:
        write_csv(args.csv, results, charts)
        print(f"\nWrote full results to {args.csv}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
