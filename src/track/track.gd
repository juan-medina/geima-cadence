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

	music.stream = song
	hero.stopped.connect(_on_hero_stopped)


func begin() -> void:
	# Must run inside the game's start gesture: on web the browser only unlocks
	# audio from a user input. Needs floor_y already set for the chosen biome.
	_spawn_obstacles(_load_beatmap_actions())
	if music:
		music.play()


func _exit_tree() -> void:
	if music:
		music.stop()


func _on_hero_stopped() -> void:
	_stopped = true


func _on_fatal_contact() -> void:
	# The blow lands at the end of the threat's own animation, so the run halts
	# here, before the hero is dead, or the threat scrolls away mid-swing.
	_stopped = true
	hero.freeze()


func get_progress() -> float:
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
		var type_name: String = type_var if type_var is String else ""

		var type: Obstacle.Type = _parse_type(type_name)
		if type == Obstacle.Type.NONE:
			push_error("Beatmap has an unknown action type: " + type_name + "!")
			continue

		_spawn_obstacle(type, time)


func _parse_type(type_name: String) -> Obstacle.Type:
	match type_name:
		"slash":
			return Obstacle.Type.SLASH
		"dash":
			return Obstacle.Type.DASH
		"slide":
			return Obstacle.Type.SLIDE
		"jump_up":
			return Obstacle.Type.JUMP_UP
	return Obstacle.Type.NONE


func _spawn_obstacle(type: Obstacle.Type, time: float) -> void:
	var scene: PackedScene = _obstacle_scene(type)
	if not scene:
		return

	var obstacle: Obstacle = scene.instantiate() as Obstacle
	if not obstacle:
		return

	obstacle.position = Vector2(hero.position.x + (time * scroll_speed), floor_y)
	obstacle.hit_player.connect(hero.take_damage)
	obstacle.fatal_contact.connect(_on_fatal_contact)
	obstacle.z_index = 1
	add_child(obstacle)


func _obstacle_scene(type: Obstacle.Type) -> PackedScene:
	match type:
		Obstacle.Type.SLASH:
			return SLASH_SCENE
		Obstacle.Type.DASH:
			return DASH_SCENE
		Obstacle.Type.SLIDE:
			return SLIDE_SCENE
		Obstacle.Type.JUMP_UP:
			return JUMP_UP_SCENE
		Obstacle.Type.NONE:
			pass
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
