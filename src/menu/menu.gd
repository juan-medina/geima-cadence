# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Menu
extends CanvasLayer

@onready var easy: Button = $Center/VBox/Buttons/Easy
@onready var normal: Button = $Center/VBox/Buttons/Normal
@onready var hard: Button = $Center/VBox/Buttons/Hard
@onready var game_start: AudioStreamPlayer2D = $GameStart


func _ready() -> void:
	match CurrentRun.difficulty:
		Track.DifficultType.EASY:
			easy.grab_focus()
		Track.DifficultType.NORMAL:
			normal.grab_focus()
		Track.DifficultType.HARD:
			hard.grab_focus()


func _on_easy_pressed() -> void:
	_go_to_game(Track.DifficultType.EASY)


func _on_normal_pressed() -> void:
	_go_to_game(Track.DifficultType.NORMAL)


func _on_hard_pressed() -> void:
	_go_to_game(Track.DifficultType.HARD)


func _go_to_game(chosen: Track.DifficultType) -> void:
	Transition.go_to_game(chosen, CurrentRun.biome)


func _on_cheat_code_entered() -> void:
	Options.invincible = true
	game_start.play()
