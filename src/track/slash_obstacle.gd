# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name SlashObstacle
extends Obstacle

const ATTACK_ANIMATION: StringName = &"attack"

# He never fully disappears: enough to see through, not enough to lose him.
const FADED_ALPHA: float = 0.6

# Which frame of the attack his blade actually connects on
@export var impact_frame: int = 8

@onready var animated_sprite2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape2d: CollisionShape2D = $CollisionShape2D

var _fade_tween: Tween


func _init() -> void:
	type = Type.SLASH


# He is near once his blade has just enough time left to reach the player
func near_time() -> float:
	var frames: SpriteFrames = animated_sprite2d.sprite_frames
	return impact_frame / frames.get_animation_speed(ATTACK_ANIMATION)


# when we are near start playing the attack
func on_player_near() -> void:
	animated_sprite2d.play(ATTACK_ANIMATION)
	_fade_tween = create_tween()
	_fade_tween.tween_property(animated_sprite2d, "modulate:a", FADED_ALPHA, near_time())


func _on_player_success() -> void:
	if _fade_tween:
		_fade_tween.kill()
	animated_sprite2d.modulate.a = 1.0
	collision_shape2d.set_deferred(&"disabled", true)
	animated_sprite2d.play("dead")
	await animated_sprite2d.animation_finished
	queue_free()


func _on_player_failure() -> void:
	hit_player.emit(damage)
