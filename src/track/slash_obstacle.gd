# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name SlashObstacle
extends Obstacle


func _init() -> void:
	type = Type.SLASH


func _on_player_success() -> void:
	queue_free()


func _on_player_failure() -> void:
	fatal_contact.emit()
	hit_player.emit(damage)
