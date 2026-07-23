# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name DashObstacle
extends Obstacle

const REVERSE_DISTANCE: float = 40.0
const REVERSE_DURATION: float = 0.25


func _init() -> void:
	type = Type.DASH


func _on_player_success() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, ^"position:x", position.x + REVERSE_DISTANCE, REVERSE_DURATION)
	await tween.finished
	queue_free()


func _on_player_failure() -> void:
	hit_player.emit(damage)
