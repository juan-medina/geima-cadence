# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Menu
extends CanvasLayer

@onready var _easy: Button = $Center/VBox/ButtonsRow/Easy
@onready var _normal: Button = $Center/VBox/ButtonsRow/Normal
@onready var _hard: Button = $Center/VBox/ButtonsRow/Hard
@onready var _exit_row: HBoxContainer = $Center/VBox/ExitRow
@onready var _cheat: AudioStreamPlayer2D = $Cheat


func _ready() -> void:
	match CurrentRun.difficulty:
		Track.DifficultType.EASY:
			_easy.grab_focus()
		Track.DifficultType.NORMAL:
			_normal.grab_focus()
		Track.DifficultType.HARD:
			_hard.grab_focus()
	if OS.has_feature(&"web"):
		_exit_row.visible = false
	Audio.connect_menu_sounds(self)


func _on_easy_pressed() -> void:
	await _go_to_game(Track.DifficultType.EASY)


func _on_normal_pressed() -> void:
	await _go_to_game(Track.DifficultType.NORMAL)


func _on_hard_pressed() -> void:
	await _go_to_game(Track.DifficultType.HARD)


func _go_to_game(chosen: Track.DifficultType) -> void:
	await Transition.go_to_game(chosen, CurrentRun.biome)


func _on_cheat_code_entered() -> void:
	Options.invincible = true
	_cheat.play()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and not OS.has_feature(&"web"):
		_on_exit_pressed()


func _on_exit_pressed() -> void:
	get_tree().quit()
