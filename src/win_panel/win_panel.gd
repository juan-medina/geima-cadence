# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name WinPanel
extends MenuPanel

const _BRONZE: Color = Color(0.65, 0.4, 0.15)

@export var rank: Rank.Level = Rank.Level.NONE:
	set(value):
		rank = value
		_star.rank = value
		_refresh()

@export var catalogue: Catalogue = null

@onready var _back_to_menu_button: Button = $VBox/HBoxContainer/BackToMenu
@onready var _star: Star = $VBox/Star
@onready var _mode_label: Label = $VBox/Mode
@onready var _song_label: Label = $VBox/Song


func _ready() -> void:
	super._ready()
	if not catalogue:
		printerr(&"WinPanel needs a Catalogue!")
		Transition.fatal_error(&"Could not load game data")
	_mode_label.add_theme_color_override(&"font_color", _BRONZE)


func first_focus_control() -> Control:
	return _back_to_menu_button


func _on_replay_pressed() -> void:
	await Transition.reload_game()


func _on_back_to_menu_pressed() -> void:
	await Transition.go_to_menu(Transition.MenuTarget.SONG_SELECTION)


func _refresh() -> void:
	var mode_text: StringName
	match GameData.difficulty:
		Track.DifficultType.EASY:
			mode_text = &"Easy"
		Track.DifficultType.NORMAL:
			mode_text = &"Normal"
		Track.DifficultType.HARD:
			mode_text = &"Hard"
	_mode_label.text = mode_text
	_song_label.text = catalogue.get_song_name(GameData.last_song_id)
