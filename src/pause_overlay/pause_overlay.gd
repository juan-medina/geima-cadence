# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name PauseOverlay
extends CanvasLayer

@onready var _resume_button: Button = $Center/VBox/Resume
@onready var _retry_button: Button = $Center/VBox/Retry


func display() -> void:
	_pause(false)


func _pause(can_resume: bool) -> void:
	_resume_button.visible = can_resume
	visible = true
	if can_resume:
		_resume_button.grab_focus()
	else:
		_retry_button.grab_focus()
	get_tree().paused = true


func _resume() -> void:
	visible = false
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		if visible:
			if _resume_button.visible:
				_on_resume_pressed()
			else:
				await _on_back_to_menu_pressed()
		else:
			_pause(true)


func _on_retry_pressed() -> void:
	get_tree().paused = false
	await Transition.reload_game()


func _on_back_to_menu_pressed() -> void:
	await Transition.go_to_menu()


func _on_resume_pressed() -> void:
	_resume()
