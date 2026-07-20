# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Hero
extends AnimatedSprite2D

enum State { IDLE, RUNNING, SLASHING, JUMP_UP, JUMP_DOWN, DASH, SLIDE }

const JUMP_HEIGHT: float = 10.0
const DASH_MATERIAL: Material = preload("res://hero/dash.tres")

var current_state: State = State.IDLE
var jump_up_duration: float = 0.0
var jump_down_duration: float = 0.0


func _ready() -> void:
	jump_up_duration = (
		sprite_frames.get_frame_count(&"jump_up") / sprite_frames.get_animation_speed(&"jump_up")
	)
	jump_down_duration = (
		sprite_frames.get_frame_count(&"jump_down")
		/ sprite_frames.get_animation_speed(&"jump_down")
	)
	animation_finished.connect(_on_animation_finished)


func start() -> void:
	if current_state == State.IDLE:
		_change_state(State.RUNNING)


func _unhandled_input(event: InputEvent) -> void:
	# we can not action until we are not idle
	if current_state == State.IDLE:
		return

	# jumping can not be interrupted, the others can
	if _is_jumping():
		return
	if event.is_action_pressed(&"right"):
		_change_state(State.SLASHING)
	elif event.is_action_pressed(&"up"):
		_change_state(State.JUMP_UP)
	elif event.is_action_pressed(&"down"):
		_change_state(State.SLIDE)
	elif event.is_action_pressed(&"left"):
		_change_state(State.DASH)


func _is_jumping() -> bool:
	return current_state == State.JUMP_UP or current_state == State.JUMP_DOWN


func _change_state(new_state: State) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	match current_state:
		State.IDLE:
			material = null
			play("&idle")
		State.RUNNING:
			material = null
			play(&"run")
		State.SLASHING:
			play(&"slash")
			material = null
		State.JUMP_UP:
			material = null
			play(&"jump_up")
			var tween: Tween = create_tween()
			# Move UP over time (ease out makes it slow down at the top like real gravity)
			(
				tween
				. tween_property(self, ^"position:y", position.y - JUMP_HEIGHT, jump_up_duration)
				. set_ease(Tween.EASE_OUT)
				. set_trans(Tween.TRANS_QUAD)
			)
		State.JUMP_DOWN:
			material = null
			play(&"jump_down")
			var tween: Tween = create_tween()
			# Move DOWN over time (ease in makes it speed up as it falls)
			(
				tween
				. tween_property(self, ^"position:y", position.y + JUMP_HEIGHT, jump_down_duration)
				. set_ease(Tween.EASE_IN)
				. set_trans(Tween.TRANS_QUAD)
			)

		State.DASH:
			material = DASH_MATERIAL
			play(&"dash")
		State.SLIDE:
			material = null
			play(&"slide")
			pass


func _on_animation_finished() -> void:
	match current_state:
		State.SLASHING, State.DASH, State.SLIDE, State.JUMP_DOWN:
			_change_state(State.RUNNING)
		State.RUNNING, State.IDLE:
			pass
		State.JUMP_UP:
			_change_state(State.JUMP_DOWN)
