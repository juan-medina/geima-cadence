# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name SlashObstacle
extends Obstacle

@onready var animated_sprite2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape2d: CollisionShape2D = $CollisionShape2D


func _init() -> void:
	type = Type.SLASH


func _on_player_success() -> void:
	if collision_shape2d:
		set_deferred("disable", true)
	if animated_sprite2d:
		animated_sprite2d.play("dead")
		await animated_sprite2d.animation_finished
	queue_free()


func _on_player_failure() -> void:
	fatal_contact.emit()
	if animated_sprite2d:
		var anim_name: StringName = &"attack"
		var sprite_frames: SpriteFrames = animated_sprite2d.sprite_frames
		var frame_count: int = sprite_frames.get_frame_count(anim_name)
		var fps: float = sprite_frames.get_animation_speed(anim_name)

		var total_duration: float = frame_count / fps
		var half_duration: float = total_duration / 2.0

		var tween: Tween = create_tween()
		tween.tween_property(animated_sprite2d, "modulate:a", 0.3, half_duration)
		tween.tween_property(animated_sprite2d, "modulate:a", 1.0, half_duration)
		animated_sprite2d.play("attack")
		await animated_sprite2d.animation_finished
	hit_player.emit(damage)
