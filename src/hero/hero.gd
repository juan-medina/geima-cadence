# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Hero
extends AnimatedSprite2D

signal health_changed(current: float)
signal stopped
signal died

enum State { IDLE, RUNNING, SLASHING, JUMP_UP, JUMP_DOWN, DASH, SLIDE, HIT, DEAD }

const JUMP_HEIGHT: float = 35.0
const HIT_MATERIAL: Material = preload("res://hero/hit.tres")

@export var max_health: float = 100.0

var current_state: State = State.IDLE
var health: float = 0.0
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
	health = max_health
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


# Called after _ready, so it must also move the baseline a cancelled jump
# restores to; _ready only captured the scene's placeholder position.
func set_ground_y(y: float) -> void:
	position.y = y
	_base_y = y


func _unhandled_input(event: InputEvent) -> void:
	if current_state == State.IDLE or current_state == State.DEAD:
		return

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
			# Air time is fixed by the animation length, so the curve may change
			# but the duration may not: the beat depends on it.
			(
				_jump_tween
				. tween_property(self, ^"position:y", position.y - JUMP_HEIGHT, jump_up_duration)
				. set_ease(Tween.EASE_OUT)
				. set_trans(Tween.TRANS_CUBIC)
			)
		State.JUMP_DOWN:
			material = null
			play(&"jump_down")
			_jump_tween = create_tween()
			(
				_jump_tween
				. tween_property(self, ^"position:y", position.y + JUMP_HEIGHT, jump_down_duration)
				. set_ease(Tween.EASE_IN)
				. set_trans(Tween.TRANS_CUBIC)
			)

		State.DASH:
			material = null
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
	# A hit can land mid-air, leaving the hero floating.
	if _jump_tween:
		_jump_tween.kill()
	position.y = _base_y


func _on_animation_finished() -> void:
	match current_state:
		State.SLASHING, State.DASH, State.SLIDE, State.JUMP_DOWN, State.HIT:
			_change_state(State.RUNNING)
		State.RUNNING, State.IDLE:
			pass
		State.DEAD:
			died.emit()
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
	var active: CollisionShape2D = _shape_for_state(current_state)
	for child: Node in _hurt_box.get_children():
		var shape: CollisionShape2D = child as CollisionShape2D
		if shape:
			# Deferred because this runs from the area_entered physics callback
			# (via the death transition); the server rejects shape changes mid-flush.
			shape.set_deferred(&"disabled", shape != active)


func _destroys(type: Obstacle.Type) -> bool:
	match current_state:
		State.SLASHING:
			return type == Obstacle.Type.SLASH
		State.DASH:
			return type == Obstacle.Type.DASH
		State.IDLE, State.RUNNING, State.JUMP_UP, State.JUMP_DOWN, State.SLIDE, State.HIT, State.DEAD:
			return false
	return false


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if current_state == State.DEAD:
		return

	var obstacle: Obstacle = area as Obstacle
	if not obstacle or obstacle.resolved:
		return

	if _destroys(obstacle.type):
		obstacle.clear()
		return

	obstacle.mark_resolved()
	_take_damage(obstacle.damage)


func _take_damage(amount: float) -> void:
	health = maxf(health - amount, 0.0)
	health_changed.emit(health)
	if health > 0.0:
		_change_state(State.HIT)
	else:
		_change_state(State.DEAD)
		stopped.emit()
