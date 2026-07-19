import sys
import json
import os
import librosa
import random

ACTIONS = ["slash", "slide", "dash", "jump_up"]

def generate_motif(length=4):
    motif = []
    for _ in range(length):
        # Apply rule: no double jumps
        if len(motif) > 0 and motif[-1] == "jump_up":
            valid_actions = ["slash", "slide", "dash"]
        else:
            # Make slash slightly more common as the default attack
            valid_actions = ["slash", "slash", "slide", "dash", "jump_up"]
        
        motif.append(random.choice(valid_actions))
    return motif

def generate_beatmap(audio_path, output_path, intro_skip=5.0, animation_duration=0.5, human_reaction=0.5):
    min_gap = animation_duration + human_reaction
    print(f"Loading audio: {audio_path}")
    y, sr = librosa.load(audio_path, sr=None)
    
    print("Detecting onset beats...")
    onset_env = librosa.onset.onset_strength(y=y, sr=sr)
    beats = librosa.onset.onset_detect(onset_envelope=onset_env, sr=sr, units='time', backtrack=True)
    
    print(f"Detected {len(beats)} raw beats. Skipping first {intro_skip}s and filtering with {min_gap}s minimum gap...")
    
    filtered_beats = []
    last_beat = -min_gap # allow beat at intro_skip
    
    for b in beats:
        if b < intro_skip:
            continue
            
        if b - last_beat >= min_gap:
            filtered_beats.append(float(b))
            last_beat = b
            
    print(f"Kept {len(filtered_beats)} beats after filtering. Assigning actions...")
    
    actions_list = []
    current_motif = []
    motif_repeats_left = 0
    
    for b in filtered_beats:
        if motif_repeats_left <= 0:
            # Generate a new 4-beat motif and repeat it for 2 to 4 cycles
            current_motif = generate_motif(4)
            motif_repeats_left = len(current_motif) * random.randint(2, 4)
            
        # Get the next action from the motif (cycling through it)
        # Using a simple index based on how many repeats are left
        motif_index = (len(current_motif) * 4 - motif_repeats_left) % len(current_motif)
        action_type = current_motif[motif_index]
        
        actions_list.append({
            "time": float(b),
            "type": action_type
        })
        
        motif_repeats_left -= 1
        
    beatmap_data = {
        "song": os.path.basename(audio_path),
        "actions": actions_list
    }
    
    with open(output_path, 'w') as f:
        json.dump(beatmap_data, f, indent=2)
        
    print(f"Beatmap successfully saved to {output_path}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python beatmap_generator.py <audio_file>")
        sys.exit(1)
        
    audio_file = sys.argv[1]
    
    if not os.path.exists(audio_file):
        print(f"Error: File not found: {audio_file}")
        sys.exit(1)
        
    base_name = os.path.splitext(audio_file)[0]
    output_file = f"{base_name}.json"
    
    generate_beatmap(audio_file, output_file)
