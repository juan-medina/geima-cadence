# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Track
extends Node2D

const SLASH_SCENE: PackedScene = preload("res://track/slash_obstacle.tscn")
const DASH_SCENE: PackedScene = preload("res://track/dash_obstacle.tscn")
const SLIDE_SCENE: PackedScene = preload("res://track/slide_obstacle.tscn")
const JUMP_UP_SCENE: PackedScene = preload("res://track/jump_up_obstacle.tscn")

@export var song: AudioStream
@export var hero: Hero
@export var scroll_speed: float = 250.0
@export var floor_y: float = 24.0

@onready var music: AudioStreamPlayer = $Music

var _started: bool = false
var _stopped: bool = false
var _last_music_time: float = 0.0


func _ready() -> void:
	if not hero:
		push_error("Track needs a Hero reference!")
		return
	if not song:
		push_error("Track needs a Song assigned!")
		return

	# The track owns its song: it holds the player and is handed the stream per
	# level, so different levels play different music without the game caring.
	music.stream = song
	hero.stopped.connect(_on_hero_stopped)


func begin() -> void:
	# The song is the spine of the run: playing it drives the scroll, the beat
	# timing and (via _process) the hero. Started from the game's start gesture
	# so the browser's audio unlock happens inside that user input.
	#
	# Obstacles are spawned here rather than in _ready so the game has already set
	# floor_y for the chosen biome; the start overlay hides them until play.
	_spawn_obstacles(_load_beatmap_actions())
	if music:
		music.play()


func _exit_tree() -> void:
	# The track owns the song, so it is the track's job to silence it on the way
	# out (e.g. a scene reload on retry).
	if music:
		music.stop()


func _on_hero_stopped() -> void:
	# The player stopped moving, so the run halts here: the scroll and the
	# progress derived from it freeze, while the song itself keeps playing.
	_stopped = true


func get_progress() -> float:
	# How far through the run we are, 0..1, for readers like the HUD energy bar.
	# Derived from the same music-driven clock as the scroll, so it freezes at
	# exactly the same moment the scroll does.
	if not music or not music.stream:
		return 0.0
	var length: float = music.stream.get_length()
	if length <= 0.0:
		return 0.0
	return clampf(_last_music_time / length, 0.0, 1.0)


func _load_beatmap_actions() -> Array:
	if not music.stream:
		push_error("Music node does not have an audio stream assigned!")
		return []

	var beatmap_file: String = music.stream.resource_path.get_basename() + ".json"
	var file: FileAccess = FileAccess.open(beatmap_file, FileAccess.READ)
	if not file:
		push_error("Could not open beatmap file: " + beatmap_file + "!")
		return []

	var json_var: Variant = JSON.parse_string(file.get_as_text())
	if not json_var is Dictionary:
		push_error("Invalid beatmap JSON format!")
		return []

	var json: Dictionary = json_var
	if not json.has("actions"):
		push_error("Beatmap JSON has no actions!")
		return []

	var actions_var: Variant = json["actions"]
	if not actions_var is Array:
		push_error("Beatmap actions must be an array!")
		return []
	var actions: Array = actions_var
	return actions


func _spawn_obstacles(actions: Array) -> void:
	for action_var: Variant in actions:
		if not action_var is Dictionary:
			continue
		var action: Dictionary = action_var

		var time_var: Variant = action.get("time", 0.0)
		var type_var: Variant = action.get("type", "")
		var time: float = time_var if time_var is float else 0.0
		var type: String = type_var if type_var is String else ""

		_spawn_obstacle(type, time)


func _spawn_obstacle(type: String, time: float) -> void:
	var scene: PackedScene = _obstacle_scene(type)
	if not scene:
		return

	var obstacle: Obstacle = scene.instantiate() as Obstacle
	if not obstacle:
		return

	# Placed so it reaches the hero exactly on its beat; the hero's hitboxes
	# decide reach, so no per-type offset is needed here.
	obstacle.position = Vector2(hero.position.x + (time * scroll_speed), floor_y)
	add_child(obstacle)


func _obstacle_scene(type: String) -> PackedScene:
	match type:
		"slash":
			return SLASH_SCENE
		"dash":
			return DASH_SCENE
		"slide":
			return SLIDE_SCENE
		"jump_up":
			return JUMP_UP_SCENE
	return null


func _process(_delta: float) -> void:
	if _stopped or not music or not music.playing:
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
