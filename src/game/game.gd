# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Game
extends Node2D

@onready var music: AudioStreamPlayer = $Music
@onready var _start_overlay: CanvasLayer = $StartOverlay
@onready var _start_button: Button = $StartOverlay/Start
@onready var _camera: Camera2D = $Camera2D


func _ready() -> void:
	# Browsers refuse to start audio before a user gesture, so the song only
	# begins once the player has pressed something.
	_start_button.pressed.connect(_on_start_pressed)

	# Workaround for Godot 4 Camera2D not re-centering after the window resizes.
	get_tree().root.size_changed.connect(_on_window_resized)


func _on_window_resized() -> void:
	_camera.enabled = false
	_camera.enabled = true
	_camera.force_update_scroll()


func _on_start_pressed() -> void:
	_start_overlay.visible = false
	music.play()


func _exit_tree() -> void:
	music.stop()
