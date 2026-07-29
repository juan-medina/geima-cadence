# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name PausePanel
extends MenuPanel

signal resume_requested
signal settings_requested

var _can_resume: bool = false

@onready var _title_label: Label = $VBox/Title
@onready var _resume_button: Button = $VBox/Resume
@onready var _retry_button: Button = $VBox/Retry


func configure(can_resume: bool) -> void:
	_can_resume = can_resume
	_resume_button.visible = can_resume
	_title_label.text = "Pause" if can_resume else "Game Over"


func first_focus_control() -> Control:
	return _resume_button if _can_resume else _retry_button


func _on_resume_pressed() -> void:
	resume_requested.emit()


func _on_retry_pressed() -> void:
	await Transition.reload_game()


func _on_back_to_menu_pressed() -> void:
	await Transition.go_to_menu()


func _on_settings_pressed() -> void:
	settings_requested.emit()
