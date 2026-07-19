# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Game
extends Node2D

@onready var music : AudioStreamPlayer = $Music

func _ready() -> void:
	music.play()

func _exit_tree() -> void:
	music.stop()
