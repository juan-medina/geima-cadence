# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name PauseOverlay
extends CanvasLayer

var _is_paused: bool = false

@onready var _resume_button: Button = $Center/VBox/Resume
@onready var _retry_button: Button = $Center/VBox/Retry


func display() -> void:
	_pause(true)


func _pause(can_resume: bool) -> void:
	_resume_button.visible = can_resume
	visible = true
	if can_resume:
		_resume_button.grab_focus()
	else:
		_retry_button.grab_focus()
	get_tree().paused = true
	_is_paused = true


func _resume() -> void:
	visible = false
	get_tree().paused = false
	_is_paused = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		if _is_paused:
			if _resume_button.visible:
				_resume()
			else:
				await _on_back_to_menu_pressed()
		else:
			_pause(true)


func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_back_to_menu_pressed() -> void:
	await Transition.go_to_menu()


func _on_resume_pressed() -> void:
	_resume()
