# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Game
extends Node2D

# Obstacles rest this far below the hero's ground line
const _OBSTACLE_OFFSET_Y: float = 22.0

# TODO: To remove when moving difficult to it own screen
static var _show_selection: bool = true

@onready var _track: Track = $Track
@onready var _biome: Biome = $Biome
@onready var _start_overlay: CanvasLayer = $StartOverlay
@onready var _easy_button: Button = $StartOverlay/Center/VBox/Buttons/Easy
@onready var _normal_button: Button = $StartOverlay/Center/VBox/Buttons/Normal
@onready var _hard_button: Button = $StartOverlay/Center/VBox/Buttons/Hard
@onready var _retry_overlay: CanvasLayer = $RetryOverlay
@onready var _retry_button: Button = $RetryOverlay/Center/VBox/Retry
@onready var _camera: Camera2D = $Camera2D
@onready var _hero: Hero = $Hero
@onready var _hud: Hud = $Hud
@onready var _cheat: CheatCode = $StartOverlay/CheatCode
@onready var _start_sound: AudioStreamPlayer = $StartSound


func _ready() -> void:
	_hero.died.connect(_on_hero_died)
	_hero.dashed.connect(_biome.dash_burst)

	# Workaround for Godot 4 Camera2D not re-centering after the window resizes.
	get_tree().root.size_changed.connect(_on_window_resized)

	_prepare_biome()

	if _show_selection:
		match CurrentRun.difficulty:
			Track.DifficultType.EASY:
				_easy_button.grab_focus()
			Track.DifficultType.NORMAL:
				_normal_button.grab_focus()
			Track.DifficultType.HARD:
				_hard_button.grab_focus()
			_:
				push_error("invalid difficulty")
	else:
		_start_run(CurrentRun.difficulty, CurrentRun.biome)


func _prepare_biome() -> void:
	_biome.load()
	var ground_y: float = _biome.ground_y()
	_hero.set_ground_y(ground_y)
	_track.floor_y = ground_y + _OBSTACLE_OFFSET_Y


func _on_window_resized() -> void:
	_camera.enabled = false
	_camera.enabled = true
	_camera.force_update_scroll()


func _on_easy_pressed() -> void:
	_start_run(Track.DifficultType.EASY, randi_range(1, 4))


func _on_normal_pressed() -> void:
	_start_run(Track.DifficultType.NORMAL, randi_range(1, 4))


func _on_hard_pressed() -> void:
	_start_run(Track.DifficultType.HARD, randi_range(1, 4))


func _on_cheat_entered() -> void:
	Options.invincible = true
	_start_sound.play()


func _start_run(chosen: Track.DifficultType, biome: int) -> void:
	CurrentRun.biome = biome
	CurrentRun.difficulty = chosen
	_start_overlay.visible = false
	_cheat.set_process_input(false)
	_track.begin()


func _on_hero_died() -> void:
	# The player has finished dying, but the health bar may still be draining
	await _hud.health_settled()

	_retry_overlay.visible = true
	_retry_button.grab_focus()
	get_tree().paused = true


func _on_retry_pressed() -> void:
	_show_selection = false
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_change_difficulty_pressed() -> void:
	_show_selection = true
	get_tree().paused = false
	get_tree().reload_current_scene()
