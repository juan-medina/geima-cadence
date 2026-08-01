# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name WinPanel
extends MenuPanel

@export var rank: Star.Rank:
	set(value):
		rank = value
		_star.rank = value

@onready var _back_to_menu_button: Button = $VBox/HBoxContainer/BackToMenu
@onready var _star: Star = $VBox/Star


func first_focus_control() -> Control:
	return _back_to_menu_button


func _on_replay_pressed() -> void:
	await Transition.reload_game()


func _on_back_to_menu_pressed() -> void:
	await Transition.go_to_menu()
