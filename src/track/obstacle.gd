# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Obstacle
extends Area2D

signal hit_player(damage: float)
signal fatal_contact

enum Type { NONE, SLASH, DASH, SLIDE, JUMP_UP }

# Set per scene: slash and dash sit far above max health, jump_up and slide chip.
@export var damage: float = 10.0

# Set by each obstacle's own script.
var type: Type = Type.NONE

var _resolved: bool = false


func resolve(action: Type) -> void:
	if _resolved:
		return
	_resolved = true
	if action == type:
		_on_player_success()
	else:
		_on_player_failure()


func _on_player_success() -> void:
	pass


func _on_player_failure() -> void:
	pass
