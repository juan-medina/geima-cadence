# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name DashObstacle
extends Obstacle

const ATTACK_ANIMATION: StringName = &"attack"

const REVERSE_DISTANCE: float = 40.0
const REVERSE_DURATION: float = 0.25

# Which frame of the attack his axe actually connects on
@export var impact_frame: int = 13

@onready var animated_sprite2d: AnimatedSprite2D = $AnimatedSprite2D


func _init() -> void:
	type = Type.DASH


# He is near once his axe has just enough time left to reach the player.
func near_time() -> float:
	var frames: SpriteFrames = animated_sprite2d.sprite_frames
	return impact_frame / frames.get_animation_speed(ATTACK_ANIMATION)


# He swings before the player has chosen, so doing nothing is answered the same
# way a wrong verb is. Nothing here may depend on the outcome.
func on_player_near() -> void:
	Sound.play_giant_wind_up()
	animated_sprite2d.play(ATTACK_ANIMATION)


# He travels right, against the scroll, while he falls. Nothing else in the game
# ever moves right, which is what makes the moment readable.
func _on_player_success() -> void:
	Sound.play_giant_death()
	Sound.play_impact()
	animated_sprite2d.play(&"dead")
	var recoil_x: float = animated_sprite2d.position.x + REVERSE_DISTANCE
	var tween: Tween = create_tween()
	tween.tween_property(animated_sprite2d, ^"position:x", recoil_x, REVERSE_DURATION)
	await animated_sprite2d.animation_finished
	queue_free()
