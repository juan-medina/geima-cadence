import argparse
import json
import os
import shutil
import subprocess
import sys

SAMPLE_RATE = 44100

# Loop-padding target and the hard ceiling it must never exceed.
TARGET_SECONDS = 120.0
CEILING_SECONDS = 170.0

FADE_SECONDS = 6.0

OGG_QUALITY = 5


def probe_duration(path):
    command = [
        "ffprobe", "-v", "error",
        "-show_entries", "format=duration", "-of", "csv=p=0", path,
    ]
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error: ffprobe failed on {path} (exit {result.returncode}).")
        print(result.stderr.strip())
        sys.exit(1)
    return float(result.stdout.strip())


# astats prints "RMS level dB" per channel; take the max.
def parse_max_rms(text):
    values = []
    label = "RMS level dB:"
    for line in text.splitlines():
        marker = line.find(label)
        if marker == -1:
            continue
        token = line[marker + len(label):].strip()
        try:
            values.append(float(token))
        except ValueError:
            continue
    return max(values) if values else None


def build_graph(segments):
    input_args = []
    chains = []
    labels = []
    for index, segment in enumerate(segments):
        input_args += ["-i", segment["path"]]
        chain = f"[{index}:a]"
        if "start" in segment:
            chain += (f"atrim=start_sample={segment['start']}:"
                      f"end_sample={segment['end']},asetpts=PTS-STARTPTS")
        else:
            chain += "asetpts=PTS-STARTPTS"
        chain += f"[a{index}]"
        chains.append(chain)
        labels.append(f"[a{index}]")
    concat_inputs = "".join(labels)
    concat = f"{concat_inputs}concat=n={len(segments)}:v=0:a=1"
    return input_args, ";".join(chains), concat


def measure_assembled(segments):
    input_args, chains, concat = build_graph(segments)
    filter_complex = f"{chains};{concat},astats=metadata=1[out]"
    command = ["ffmpeg", "-hide_banner", *input_args,
               "-filter_complex", filter_complex, "-map", "[out]", "-f", "null", "-"]
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error: ffmpeg failed to analyse assembled audio (exit {result.returncode}).")
        print(result.stderr.strip())
        sys.exit(1)
    rms = parse_max_rms(result.stderr)
    if rms is None:
        print("Error: could not read RMS level from astats output.")
        sys.exit(1)
    return rms


def measure_file(path):
    command = ["ffmpeg", "-hide_banner", "-i", path,
               "-af", "astats=metadata=1", "-f", "null", "-"]
    result = subprocess.run(command, capture_output=True, text=True)
    return parse_max_rms(result.stderr)


def plan_segments(entry):
    if "loop" in entry:
        intro = entry["input"]
        loop = entry["loop"]
        base_seconds = probe_duration(intro) + probe_duration(loop)
        segments = [{"path": intro}, {"path": loop}]
        loop_segment = {"path": loop}
        unit_seconds = probe_duration(loop)
        kind = "intro+loop"
        tail = False
    elif "loop_start_samples" in entry:
        path = entry["input"]
        loop_start = entry["loop_start_samples"]
        loop_end = loop_start + entry["loop_length_samples"]
        file_samples = round(probe_duration(path) * SAMPLE_RATE)
        base_seconds = loop_end / SAMPLE_RATE
        segments = [{"path": path, "start": 0, "end": loop_end}]
        loop_segment = {"path": path, "start": loop_start, "end": loop_end}
        unit_seconds = entry["loop_length_samples"] / SAMPLE_RATE
        kind = "single+loop"
        tail = (file_samples - loop_end) > int(0.1 * SAMPLE_RATE)
    else:
        path = entry["input"]
        base_seconds = probe_duration(path)
        segments = [{"path": path}]
        loop_segment = None
        unit_seconds = 0.0
        kind = "single"
        tail = False

    total = base_seconds
    while loop_segment is not None and total < TARGET_SECONDS \
            and total + unit_seconds <= CEILING_SECONDS:
        segments.append(dict(loop_segment))
        total += unit_seconds

    return segments, total, kind, tail


def render(entry, target_level):
    output_path = entry["output"]
    segments, total, kind, tail = plan_segments(entry)

    measured = measure_assembled(segments)
    gain = target_level - measured

    fade_start = max(0.0, total - FADE_SECONDS)
    input_args, chains, concat = build_graph(segments)
    filter_complex = (f"{chains};{concat},volume={gain:.2f}dB,"
                      f"afade=t=out:st={fade_start:.3f}:d={FADE_SECONDS}[out]")

    os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
    command = ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y", *input_args,
               "-filter_complex", filter_complex, "-map", "[out]",
               "-c:a", "libvorbis", "-q:a", str(OGG_QUALITY),
               "-ar", str(SAMPLE_RATE), "-ac", "2", output_path]
    result = subprocess.run(command)
    if result.returncode != 0:
        print(f"Error: ffmpeg failed to write {output_path} (exit {result.returncode}).")
        sys.exit(1)

    achieved = measure_file(output_path)
    minutes, seconds = divmod(int(round(total)), 60)
    achieved_text = f"{achieved:6.1f}" if achieved is not None else "   n/a"
    print(f"{os.path.basename(output_path):<26} {kind:<12} "
          f"{minutes}:{seconds:02d}  rms {measured:6.1f} -> {achieved_text} dB "
          f"(target {target_level}, gain {gain:+.1f})")

    if total < TARGET_SECONDS:
        target_minutes, target_seconds = divmod(int(TARGET_SECONDS), 60)
        print(f"  *** WARNING: {os.path.basename(output_path)} IS "
              f"{minutes}:{seconds:02d}, SHORTER THAN THE "
              f"{target_minutes}:{target_seconds:02d} TARGET ***")
    if tail:
        print(f"  *** WARNING: {os.path.basename(entry['input'])} HAS AUDIO "
              f"AFTER ITS LOOP END ***")


def main():
    parser = argparse.ArgumentParser(
        description="Assemble, normalise and fade each song, output as Ogg Vorbis."
    )
    parser.add_argument("--manifest", default=os.path.join("scripts", "config", "songs.json"),
                        help="Song manifest (default: scripts/config/songs.json)")
    args = parser.parse_args()

    for tool in ("ffmpeg", "ffprobe"):
        if shutil.which(tool) is None:
            print(f"Error: {tool} not found on PATH.")
            sys.exit(1)

    if not os.path.exists(args.manifest):
        print(f"Error: manifest not found: {args.manifest}")
        sys.exit(1)

    with open(args.manifest, encoding="utf-8") as handle:
        manifest = json.load(handle)

    target_level = manifest["target_level"]

    for entry in manifest["songs"]:
        for key in ("input", "loop"):
            path = entry.get(key)
            if path is not None and not os.path.exists(path):
                print(f"Error: input not found: {path}")
                sys.exit(1)

    for entry in manifest["songs"]:
        render(entry, target_level)


if __name__ == "__main__":
    main()
