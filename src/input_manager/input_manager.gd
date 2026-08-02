# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

extends Node

const MOUSE_HIDE_TIME: float = 2.5

var _notifications_enabled: bool = false
var _mouse_hide_timer: Timer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_mouse_hide_timer = Timer.new()
	_mouse_hide_timer.wait_time = MOUSE_HIDE_TIME
	_mouse_hide_timer.one_shot = true
	_mouse_hide_timer.timeout.connect(_on_mouse_hide_timer_timeout)
	add_child(_mouse_hide_timer)

	Input.joy_connection_changed.connect(_on_joy_connection_changed)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_mouse_hide_timer.start()


func _on_mouse_hide_timer_timeout() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func enable_notifications() -> void:
	if _notifications_enabled:
		return
	_notifications_enabled = true
	if not Input.get_connected_joypads().is_empty():
		Toast.show_message("Controller Detected")


func _on_joy_connection_changed(_device: int, connected: bool) -> void:
	if not _notifications_enabled:
		return
	if connected:
		Toast.show_message("Controller Connected")
	else:
		Toast.show_message("Controller Disconnected")
