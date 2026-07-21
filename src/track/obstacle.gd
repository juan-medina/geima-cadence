# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Obstacle
extends Area2D

@export var type: String = ""
# Health this obstacle costs the hero on a missed beat. Fatal threats (slash,
# dash) set this far above max health; casual ones (jump_up, slide) just chip.
@export var damage: float = 10.0

var resolved: bool = false


func clear() -> void:
	# A landed attack destroys the threat.
	if resolved:
		return
	resolved = true
	queue_free()


func mark_resolved() -> void:
	# Dodged/passed obstacles stay on screen but must not be judged twice.
	resolved = true
