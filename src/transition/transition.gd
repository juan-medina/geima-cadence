# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

extends Node2D

@export var game_scene: PackedScene = null

@export var menu_scene: PackedScene = null


func go_to_game(difficulty: Track.DifficultType, biome: int) -> void:
	if not game_scene:
		push_error("Game scene is not set in the Transition node.")
		get_tree().quit()
		return
	CurrentRun.difficulty = difficulty
	CurrentRun.biome = biome
	get_tree().change_scene_to_packed(game_scene)


func go_to_menu() -> void:
	if not menu_scene:
		push_error("Menu scene is not set in the Transition node.")
		get_tree().quit()
		return
	get_tree().change_scene_to_packed(menu_scene)
