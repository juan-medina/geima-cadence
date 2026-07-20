# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Obstacle
extends Area2D

# Missing these on the beat only hurts; the others (slash, dash) are fatal threats.
const CASUAL_TYPES: Array[String] = ["jump_up", "slide"]

@export var type: String = ""

var resolved: bool = false


func is_casual() -> bool:
	return type in CASUAL_TYPES


func clear() -> void:
	# A landed attack destroys the threat.
	if resolved:
		return
	resolved = true
	queue_free()


func mark_resolved() -> void:
	# Dodged/passed obstacles stay on screen but must not be judged twice.
	resolved = true
