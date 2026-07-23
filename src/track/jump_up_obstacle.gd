# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name JumpUpObstacle
extends Obstacle

@onready var animated_sprite2d: AnimatedSprite2D = $AnimatedSprite2D


func _init() -> void:
	type = Type.JUMP_UP


func _on_player_success() -> void:
	pass


func _on_player_failure() -> void:
	hit_player.emit(damage)
	if animated_sprite2d:
		animated_sprite2d.play("dead")
		await animated_sprite2d.animation_finished
	queue_free()
