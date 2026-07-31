# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name SongSelectionPanel
extends MenuPanel

signal back_requested

@export var catalogue: Catalogue = null

@onready var _play_button: Button = %Play
@onready var _easy_button: DifficultyButton = %Easy


func _ready() -> void:
	super._ready()
	if not catalogue or not catalogue.biomes or catalogue.biomes.is_empty():
		printerr(&"BiomeCarouselPanel needs a non-empty Catalogue!")
		get_tree().quit()
		return


func first_focus_control() -> Control:
	return _play_button


func _on_back_pressed() -> void:
	back_requested.emit()


func _selected_difficulty() -> Track.DifficultType:
	return (_easy_button.button_group.get_pressed_button() as DifficultyButton).difficulty


func _on_play_pressed() -> void:
	await Transition.go_to_game(_selected_difficulty(), 1)
