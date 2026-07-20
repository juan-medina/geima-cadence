# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Game
extends Node2D

@onready var music: AudioStreamPlayer = $Music
@onready var _start_overlay: CanvasLayer = $StartOverlay
@onready var _start_button: Button = $StartOverlay/Start


func _ready() -> void:
	# Browsers refuse to start audio before a user gesture, so the song only
	# begins once the player has pressed something.
	_start_button.pressed.connect(_on_start_pressed)


func _on_start_pressed() -> void:
	_start_overlay.visible = false
	music.play()


func _exit_tree() -> void:
	music.stop()
