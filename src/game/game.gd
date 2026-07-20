# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Game
extends Node2D

# Survives scene reloads: once the first user gesture has unlocked audio,
# a retry can start the song straight away without asking to play again.
static var _show_play: bool = true

@onready var music: AudioStreamPlayer = $Music
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

	# Workaround for Godot 4 Camera2D not re-centering after the window resizes.
	get_tree().root.size_changed.connect(_on_window_resized)

	if _show_play:
		# Focused so ui_accept (space / gamepad) presses it without a mouse.
		_start_button.grab_focus()
	else:
		_on_start_pressed()


func _on_window_resized() -> void:
	_camera.enabled = false
	_camera.enabled = true
	_camera.force_update_scroll()


func _on_start_pressed() -> void:
	_start_overlay.visible = false
	music.play()


func _on_hero_died() -> void:
	# Halting the song also freezes everything driven by it (scroll, song bar).
	music.stop()
	_retry_overlay.visible = true
	_retry_button.grab_focus()


func _on_retry_pressed() -> void:
	_show_play = false
	get_tree().reload_current_scene()


func _exit_tree() -> void:
	music.stop()
