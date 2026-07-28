# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name StagePanel
extends PanelContainer

signal back_requested

@onready var _easy_button: Button = $VBox/Easy
@onready var _normal_button: Button = $VBox/Normal
@onready var _hard_button: Button = $VBox/Hard


func _ready() -> void:
	Audio.connect_menu_sounds(self)


func open() -> void:
	visible = true
	match CurrentRun.difficulty:
		Track.DifficultType.EASY:
			_easy_button.grab_focus()
		Track.DifficultType.NORMAL:
			_normal_button.grab_focus()
		Track.DifficultType.HARD:
			_hard_button.grab_focus()


func close() -> void:
	visible = false


func _on_easy_pressed() -> void:
	await _start(Track.DifficultType.EASY)


func _on_normal_pressed() -> void:
	await _start(Track.DifficultType.NORMAL)


func _on_hard_pressed() -> void:
	await _start(Track.DifficultType.HARD)


func _start(chosen: Track.DifficultType) -> void:
	await Transition.go_to_game(chosen, CurrentRun.biome)


func _on_back_pressed() -> void:
	back_requested.emit()
