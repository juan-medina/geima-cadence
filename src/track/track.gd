# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Track
extends Node2D

const SLASH_SCENE: PackedScene = preload("res://track/slash_obstacle.tscn")
const DASH_SCENE: PackedScene = preload("res://track/dash_obstacle.tscn")
const SLIDE_SCENE: PackedScene = preload("res://track/slide_obstacle.tscn")
const JUMP_UP_SCENE: PackedScene = preload("res://track/jump_up_obstacle.tscn")

@export var music: AudioStreamPlayer
@export var hero: Hero
@export var scroll_speed: float = 250.0
@export var floor_y: float = 24.0

var _started: bool = false
var _last_music_time: float = 0.0


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
		push_error("Could not open beatmap file: " + beatmap_file + "!")
		return

	var json_var: Variant = JSON.parse_string(file.get_as_text())
	if not json_var is Dictionary:
		push_error("Invalid beatmap JSON forma!")
		return

	var json: Dictionary = json_var
	if not json.has("actions"):
		push_error("Invalid beatmap JSON format!")
		return

	var spawn_offset_x: float = hero.position.x
	var actions_var: Variant = json["actions"]
	if not actions_var is Array:
		push_error("Beatmap actions must be an array!")
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

		var obstacle: Node2D
		var local_x: float = spawn_offset_x + (time * scroll_speed)

		match type:
			"slash":
				obstacle = SLASH_SCENE.instantiate() as Node2D
			"dash":
				obstacle = DASH_SCENE.instantiate() as Node2D
			"slide":
				obstacle = SLIDE_SCENE.instantiate() as Node2D
			"jump_up":
				obstacle = JUMP_UP_SCENE.instantiate() as Node2D
			_:
				continue

		if obstacle:
			obstacle.position = Vector2(local_x, floor_y)
			add_child(obstacle)


func _process(_delta: float) -> void:
	if not music or not music.playing:
		return

	# On web `playing` flips true before the browser's audio context actually
	# starts; until then playback_position stays 0 and only mix jitter moves.
	if music.get_playback_position() <= 0.0:
		return

	var current_music_time: float = (
		music.get_playback_position()
		+ AudioServer.get_time_since_last_mix()
		- AudioServer.get_output_latency()
	)

	# Threads make this jittery; never let the clock run backwards.
	if current_music_time <= _last_music_time:
		return
	_last_music_time = current_music_time

	position.x = -current_music_time * scroll_speed
	if not _started:
		hero.start()
		_started = true
