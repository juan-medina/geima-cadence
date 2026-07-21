# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Hero
extends AnimatedSprite2D

signal hurt
signal died

enum State { IDLE, RUNNING, SLASHING, JUMP_UP, JUMP_DOWN, DASH, SLIDE, HIT, DEAD }

const JUMP_HEIGHT: float = 10.0
const DASH_MATERIAL: Material = preload("res://hero/dash.tres")
const HIT_MATERIAL: Material = preload("res://hero/hit.tres")

var current_state: State = State.IDLE
var jump_up_duration: float = 0.0
var jump_down_duration: float = 0.0

var _jump_tween: Tween
var _base_y: float = 0.0

@onready var _hurt_box: Area2D = $HurtBox
@onready var _shape_running: CollisionShape2D = $HurtBox/ShapeRunning
@onready var _shape_slash: CollisionShape2D = $HurtBox/ShapeSlash
@onready var _shape_dash: CollisionShape2D = $HurtBox/ShapeDash
@onready var _shape_slide: CollisionShape2D = $HurtBox/ShapeSlide
@onready var _shape_jump: CollisionShape2D = $HurtBox/ShapeJump


func _ready() -> void:
	jump_up_duration = (
		sprite_frames.get_frame_count(&"jump_up") / sprite_frames.get_animation_speed(&"jump_up")
	)
	jump_down_duration = (
		sprite_frames.get_frame_count(&"jump_down")
		/ sprite_frames.get_animation_speed(&"jump_down")
	)
	_base_y = position.y
	animation_finished.connect(_on_animation_finished)
	_hurt_box.area_entered.connect(_on_hurt_box_area_entered)
	_update_active_shape()


func start() -> void:
	if current_state == State.IDLE:
		_change_state(State.RUNNING)


func _unhandled_input(event: InputEvent) -> void:
	# we can not action until we are not idle, and never again once dead
	if current_state == State.IDLE or current_state == State.DEAD:
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
	_update_active_shape()
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
			_jump_tween = create_tween()
			# Move UP over time (ease out makes it slow down at the top like real gravity)
			(
				_jump_tween
				. tween_property(self, ^"position:y", position.y - JUMP_HEIGHT, jump_up_duration)
				. set_ease(Tween.EASE_OUT)
				. set_trans(Tween.TRANS_QUAD)
			)
		State.JUMP_DOWN:
			material = null
			play(&"jump_down")
			_jump_tween = create_tween()
			# Move DOWN over time (ease in makes it speed up as it falls)
			(
				_jump_tween
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
		State.HIT:
			_cancel_jump()
			material = HIT_MATERIAL
			play(&"hit")
		State.DEAD:
			_cancel_jump()
			material = null
			play(&"dead")


func _cancel_jump() -> void:
	# A hit can land mid-air; abort the jump tween so the hero is not left floating.
	if _jump_tween:
		_jump_tween.kill()
	position.y = _base_y


func _on_animation_finished() -> void:
	match current_state:
		State.SLASHING, State.DASH, State.SLIDE, State.JUMP_DOWN, State.HIT:
			_change_state(State.RUNNING)
		State.RUNNING, State.IDLE, State.DEAD:
			pass
		State.JUMP_UP:
			_change_state(State.JUMP_DOWN)


func _shape_for_state(state: State) -> CollisionShape2D:
	match state:
		State.SLASHING:
			return _shape_slash
		State.DASH:
			return _shape_dash
		State.SLIDE:
			return _shape_slide
		State.JUMP_UP, State.JUMP_DOWN:
			return _shape_jump
		State.IDLE, State.RUNNING, State.HIT, State.DEAD:
			pass
	return _shape_running


func _update_active_shape() -> void:
	# Only the shape matching the current pose collides; the rest are turned off.
	var active: CollisionShape2D = _shape_for_state(current_state)
	for child: Node in _hurt_box.get_children():
		var shape: CollisionShape2D = child as CollisionShape2D
		if shape:
			shape.disabled = shape != active


func _attacking_type() -> String:
	# The obstacle type the current attack pose can destroy, or "" if not attacking.
	match current_state:
		State.SLASHING:
			return "slash"
		State.DASH:
			return "dash"
		State.IDLE, State.RUNNING, State.JUMP_UP, State.JUMP_DOWN, State.SLIDE, State.HIT, State.DEAD:
			return ""
	return ""


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if current_state == State.DEAD:
		return

	# The active pose shape decides this: the slash/dash shape reaches the threat
	# while attacking, so destroy it; any other pose that touches it missed.
	var obstacle: Obstacle = area as Obstacle
	if not obstacle or obstacle.resolved:
		return

	if _attacking_type() == obstacle.type:
		obstacle.clear()
		return

	obstacle.mark_resolved()
	hurt.emit()

	if obstacle.is_casual():
		_change_state(State.HIT)
	else:
		_change_state(State.DEAD)
		died.emit()
