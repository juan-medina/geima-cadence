# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name SongSelectionPanel
extends MenuPanel

signal back_requested

@export var catalogue: Catalogue = null

@onready var _play_button: Button = %Play

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


func _on_play_pressed() -> void:
	await Transition.go_to_game(Track.DifficultType.EASY, 1)
