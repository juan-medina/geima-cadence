# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Track
extends Node2D

@export var music: AudioStreamPlayer
@export var hero: Node2D
@export var scroll_speed: float = 250.0
@export var floor_y: float = 24.0

func _ready() -> void:
	if not music or not hero:
		push_error("Track needs Music and Hero references!")
		return
		
	if not music.stream:
		push_error("Music node does not have an audio stream assigned!")
		return
		
	var beatmap_file: String = music.stream.resource_path.get_basename() + ".json"
		
	var file: FileAccess = FileAccess.open(beatmap_file, FileAccess.READ)
	if not file:
		push_error("Could not open beatmap file: " + beatmap_file)
		return
		
	var json_var: Variant = JSON.parse_string(file.get_as_text())
	if not json_var is Dictionary:
		push_error("Invalid beatmap JSON format")
		return
		
	var json: Dictionary = json_var
	if not json.has("actions"):
		push_error("Invalid beatmap JSON format")
		return
		
	var spawn_offset_x: float = hero.position.x
	var actions_var: Variant = json["actions"]
	if not actions_var is Array:
		push_error("Beatmap actions must be an array")
		return
	var actions: Array = actions_var
	
	for action_var: Variant in actions:
		if not action_var is Dictionary:
			continue
		var action: Dictionary = action_var
		
		var time_var: Variant = action.get("time", 0.0)
		var type_var: Variant = action.get("type", "")
		
		var time: float = time_var if time_var is float else 0.0
		var type: String = type_var if type_var is String else ""
		
		var rect: ColorRect = ColorRect.new()
		var local_x: float = spawn_offset_x + (time * scroll_speed)
		
		match type:
			"slash":
				rect.size = Vector2(10, 34)
				rect.position = Vector2(local_x, floor_y - 34)
				rect.color = Color.GREEN
			"dash":
				rect.size = Vector2(40, 44)
				rect.position = Vector2(local_x, floor_y - 44)
				rect.color = Color.ORANGE
			"slide":
				rect.size = Vector2(20, 30)
				rect.position = Vector2(local_x, floor_y - 54)
				rect.color = Color.CYAN
			"jump_up":
				rect.size = Vector2(20, 10)
				rect.position = Vector2(local_x, floor_y - 10)
				rect.color = Color.YELLOW
		
		add_child(rect)

func _process(_delta: float) -> void:
	if music and music.playing:
		var current_music_time: float = music.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
		position.x = -current_music_time * scroll_speed