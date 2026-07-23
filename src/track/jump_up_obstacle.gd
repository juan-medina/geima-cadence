# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name JumpUpObstacle
extends Obstacle


func _init() -> void:
	type = Type.JUMP_UP


func _on_player_success() -> void:
	pass


func _on_player_failure() -> void:
	hit_player.emit(damage)
	queue_free()
