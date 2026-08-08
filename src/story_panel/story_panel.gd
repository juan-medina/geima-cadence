# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name StoryPanel
extends MenuPanel

@onready var _intro_button: Button = $VBox/Intro


func first_focus_control() -> Control:
	return _intro_button


func _on_intro_pressed() -> void:
	await Transition.go_to_story(&"intro")


func _on_ending_pressed() -> void:
	await Transition.go_to_story(&"escape")


func _on_secret_pressed() -> void:
	await Transition.go_to_story(&"secret")


func _on_back_pressed() -> void:
	back_requested.emit()
