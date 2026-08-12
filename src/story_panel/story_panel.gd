# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name StoryPanel
extends MenuPanel

@onready var _intro_button: Button = $VBox/Intro
@onready var _ending_button: Button = $VBox/Ending
@onready var _secret_button: Button = $VBox/Secret


func _ready() -> void:
	super._ready()
	_ending_button.disabled = not GameData.ending_unlocked(Endings.ESCAPE_ID)
	_secret_button.disabled = not GameData.ending_unlocked(Endings.SECRET_ID)


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
