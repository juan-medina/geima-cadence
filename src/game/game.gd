# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Game
extends Node2D

# Obstacles rest this far below the hero's ground line
const _OBSTACLE_OFFSET_Y: float = 22.0

# Survives scene reloads: once the first user gesture has unlocked audio,
# a retry can start the song straight away without asking to play again.
static var _show_play: bool = true

@onready var _track: Track = $Track
@onready var _biome: Biome = $Biome
@onready var _start_overlay: CanvasLayer = $StartOverlay
@onready var _start_button: Button = $StartOverlay/Start
@onready var _retry_overlay: CanvasLayer = $RetryOverlay
@onready var _retry_button: Button = $RetryOverlay/Retry
@onready var _camera: Camera2D = $Camera2D
@onready var _hero: Hero = $Hero


func _ready() -> void:
	# Browsers refuse to start audio before a user gesture, so the song only
	# begins once the player has pressed something.
	_start_button.pressed.connect(_on_start_pressed)
	_retry_button.pressed.connect(_on_retry_pressed)
	_hero.died.connect(_on_hero_died)
	_hero.dashed.connect(_biome.dash_burst)

	# Workaround for Godot 4 Camera2D not re-centering after the window resizes.
	get_tree().root.size_changed.connect(_on_window_resized)

	# Temporary: a random biome each load so every one gets seen while testing.
	# This will come from stage selection later.
	_set_biome(randi_range(1, 4))

	if _show_play:
		# Focused so ui_accept (space / gamepad) presses it without a mouse.
		_start_button.grab_focus()
	else:
		_on_start_pressed()


# Applies a biome: the Biome node loads its art and colours, then hands back the
# ground line the hero and obstacles share. Background and Fog read the Biome
# directly, so they need no telling — they redraw every frame. The track spawns
# its obstacles in begin(), after this has set floor_y.
func _set_biome(biome: int) -> void:
	_biome.set_biome(biome)
	var ground_y: float = _biome.ground_y()
	_hero.set_ground_y(ground_y)
	_track.floor_y = ground_y + _OBSTACLE_OFFSET_Y


func _on_window_resized() -> void:
	_camera.enabled = false
	_camera.enabled = true
	_camera.force_update_scroll()


func _on_start_pressed() -> void:
	_start_overlay.visible = false
	# The song lives in the track now; the game just asks it to begin the run.
	_track.begin()


func _on_hero_died() -> void:
	# The player has finished dying; only now is the retry offered. A delay
	# before this (e.g. hold on the corpse for a beat) would belong here.
	_retry_overlay.visible = true
	_retry_button.grab_focus()


func _on_retry_pressed() -> void:
	_show_play = false
	get_tree().reload_current_scene()
