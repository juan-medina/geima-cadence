# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Track
extends Node2D

enum DifficultType { EASY, NORMAL, HARD }

const SLASH_SCENE: PackedScene = preload("res://track/slash_obstacle.tscn")
const DASH_SCENE: PackedScene = preload("res://track/dash_obstacle.tscn")
const SLIDE_SCENE: PackedScene = preload("res://track/slide_obstacle.tscn")
const JUMP_UP_SCENE: PackedScene = preload("res://track/jump_up_obstacle.tscn")

@export var song: AudioStream
@export var hero: Hero
@export var scroll_speed: float = 250.0
@export var floor_y: float = 24.0

var _started: bool = false
var _stopped: bool = false
var _last_music_time: float = 0.0

var _approaching: Array[Obstacle] = []
var _near_times: PackedFloat32Array = PackedFloat32Array()
var _next_near: int = 0

@onready var music: AudioStreamPlayer = $Music


func _ready() -> void:
	if not hero:
		printerr(&"Track needs a Hero reference!")
		get_tree().quit()
		return
	if not song:
		printerr(&"Track needs a Song assigned!")
		get_tree().quit()
		return

	music.stream = song
	hero.stopped.connect(_on_hero_stopped)


func begin() -> void:
	_spawn_obstacles(_load_beatmap_actions())
	if music:
		music.play()


func _exit_tree() -> void:
	if music:
		music.stop()


func _on_hero_stopped() -> void:
	_stopped = true


func get_progress() -> float:
	if not music or not music.stream:
		return 0.0
	var length: float = music.stream.get_length()
	if length <= 0.0:
		return 0.0
	return clampf(_last_music_time / length, 0.0, 1.0)


func _load_beatmap_actions() -> Array:
	var difficulty: StringName = _difficulty()
	if not music.stream:
		printerr(&"Music node does not have an audio stream assigned!")
		get_tree().quit()
		return []

	var beatmap_file: String = music.stream.resource_path.get_basename() + &".json"
	var file: FileAccess = FileAccess.open(beatmap_file, FileAccess.READ)
	if not file:
		printerr(&"Could not open beatmap file: " + beatmap_file + &"!")
		get_tree().quit()
		return []

	var json_var: Variant = JSON.parse_string(file.get_as_text())
	if not json_var is Dictionary:
		printerr(&"Invalid beatmap JSON format!")
		get_tree().quit()
		return []

	var json: Dictionary = json_var
	if not json.has("difficulties"):
		printerr(&"Beatmap JSON has no difficulties!")
		get_tree().quit()
		return []

	var difficulties_var: Variant = json[&"difficulties"]
	if not difficulties_var is Dictionary:
		printerr(&"Beatmap difficulties must be a dictionary!")
		get_tree().quit()
		return []
	var difficulties: Dictionary = difficulties_var

	return _extract_actions(difficulties, difficulty)


func _extract_actions(difficulties: Dictionary, difficulty: StringName) -> Array:
	if not difficulties.has(difficulty):
		printerr(&"Beatmap has no '" + difficulty + &"' difficulty!")
		get_tree().quit()
		return []

	var entry_var: Variant = difficulties[difficulty]
	if not entry_var is Dictionary:
		printerr(&"Beatmap '" + difficulty + &"' difficulty must be a dictionary!")
		get_tree().quit()
		return []
	var entry: Dictionary = entry_var

	if not entry.has("actions"):
		printerr(&"Beatmap '" + difficulty + &"' difficulty has no actions!")
		get_tree().quit()
		return []

	var actions_var: Variant = entry[&"actions"]
	if not actions_var is Array:
		printerr(&"Beatmap actions must be an array!")
		get_tree().quit()
		return []
	var actions: Array = actions_var
	return actions


func _spawn_obstacles(actions: Array) -> void:
	for action_var: Variant in actions:
		if not action_var is Dictionary:
			continue
		var action: Dictionary = action_var

		var time_var: Variant = action.get(&"time", 0.0)
		var type_var: Variant = action.get(&"type", &"")
		var time: float = time_var if time_var is float else 0.0
		var type_name: String = type_var if type_var is String else &""

		var type: Obstacle.Type = _parse_type(type_name)
		if type == Obstacle.Type.NONE:
			printerr(&"Beatmap has an unknown action type: " + type_name + &"!")
			get_tree().quit()
			return

		_spawn_obstacle(type, time)


func _parse_type(type_name: String) -> Obstacle.Type:
	match type_name:
		&"slash":
			return Obstacle.Type.SLASH
		&"dash":
			return Obstacle.Type.DASH
		&"slide":
			return Obstacle.Type.SLIDE
		&"jump_up":
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
	obstacle.z_index = 1
	add_child(obstacle)

	# Both sides use scroll_speed, so a threat placed for this beat reaches the
	# hero at exactly this music time, and counts him near its own span before.
	_approaching.append(obstacle)
	_near_times.append(time - obstacle.near_time())


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

	if music.get_playback_position() <= 0.0:
		return

	var play_back_position: float = music.get_playback_position()
	var time_since_last_mix: float = AudioServer.get_time_since_last_mix()
	var output_latency: float = AudioServer.get_output_latency()
	var current_music_time: float = play_back_position + time_since_last_mix - output_latency

	# Threads make this jittery; never let the clock run backwards.
	if current_music_time <= _last_music_time:
		return
	_last_music_time = current_music_time

	position.x = -current_music_time * scroll_speed
	_notify_player_near(current_music_time)
	if not _started:
		hero.start()
		_started = true


func _notify_player_near(music_time: float) -> void:
	while _next_near < _near_times.size() and music_time >= _near_times[_next_near]:
		var obstacle: Obstacle = _approaching[_next_near]
		if is_instance_valid(obstacle):
			obstacle.on_player_near()
		_next_near += 1


func _difficulty() -> StringName:
	return _difficulty_to_string(GameData.difficulty)


func _difficulty_to_string(difficulty: DifficultType) -> StringName:
	match difficulty:
		Track.DifficultType.EASY:
			return &"easy"
		Track.DifficultType.NORMAL:
			return &"normal"
		Track.DifficultType.HARD:
			return &"hard"
		_:
			printerr(&"invalid difficulty")
			get_tree().quit()
			return &""
