# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Obstacle
extends Area2D

signal hit_player(damage: float)

enum Type { NONE, SLASH, DASH, SLIDE, JUMP_UP }

# Set per scene: slash and dash sit far above max health, jump_up and slide chip.
@export var damage: float = 10.0

# Set by each obstacle's own script.
var type: Type = Type.NONE

var _resolved: bool = false


# How long before contact this threat counts the player as near. A threat that
# acts on the beat asks for the time its own action takes to land.
func near_time() -> float:
	return 0.0


# The player is near_time() away. Runs before he has committed, so nothing here
# may depend on what he ends up doing.
func on_player_near() -> void:
	pass


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
