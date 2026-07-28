# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name PausePanel
extends PanelContainer

signal resume_requested
signal settings_requested

@onready var _title_label: Label = $VBox/Title
@onready var _resume_button: Button = $VBox/Resume
@onready var _retry_button: Button = $VBox/Retry


func _ready() -> void:
	Audio.connect_menu_sounds(self)


func open(can_resume: bool) -> void:
	_resume_button.visible = can_resume
	_title_label.text = "Pause" if can_resume else "Game Over"
	visible = true
	if can_resume:
		_resume_button.grab_focus()
	else:
		_retry_button.grab_focus()


func close() -> void:
	visible = false


func _on_resume_pressed() -> void:
	resume_requested.emit()


func _on_retry_pressed() -> void:
	await Transition.reload_game()


func _on_back_to_menu_pressed() -> void:
	await Transition.go_to_menu()


func _on_settings_pressed() -> void:
	settings_requested.emit()
