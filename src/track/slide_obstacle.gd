# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name SlideObstacle
extends Obstacle


func _init() -> void:
	type = Type.SLIDE


func _on_player_success() -> void:
	pass


func _on_player_failure() -> void:
	hit_player.emit(damage)
	queue_free()
