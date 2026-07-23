# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Obstacle
extends Area2D

enum Type { NONE, SLASH, DASH, SLIDE, JUMP_UP }

# Set per scene: slash and dash sit far above max health, jump_up and slide chip.
@export var damage: float = 10.0

# Set by each obstacle's own script.
var type: Type = Type.NONE
var resolved: bool = false


func clear() -> void:
	if resolved:
		return
	resolved = true
	queue_free()


func mark_resolved() -> void:
	# Stays on screen, so it must never be judged twice.
	resolved = true
