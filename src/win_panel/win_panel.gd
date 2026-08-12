# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name WinPanel
extends MenuPanel

const _BRONZE: Color = Color(0.65, 0.4, 0.15)

const _AUTO_RETURN_SECONDS: int = 30

@export var rank: Rank.Level = Rank.Level.NONE:
	set(value):
		rank = value
		_star.rank = value
		_refresh()

@export var catalogue: Catalogue = null

var _remaining: int = 0
var _pending_ending: Endings.Kind = Endings.Kind.NONE

@onready var _replay_button: Button = $VBox/HBoxContainer/Replay
@onready var _back_to_menu_button: Button = $VBox/HBoxContainer/BackToMenu
@onready var _auto_return: Timer = $AutoReturn
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


func begin_auto_return() -> void:
	_pending_ending = _resolve_pending_ending()
	_replay_button.visible = _pending_ending == Endings.Kind.NONE
	_remaining = _AUTO_RETURN_SECONDS
	_update_back_to_menu_label()
	_auto_return.start()


func _on_auto_return_tick() -> void:
	_remaining -= 1
	if _remaining <= 0:
		_auto_return.stop()
		_back_to_menu_button.pressed.emit()
		return
	_update_back_to_menu_label()


func _update_back_to_menu_label() -> void:
	_back_to_menu_button.text = &"Back to Menu (%d)" % _remaining


func _on_replay_pressed() -> void:
	_auto_return.stop()
	await Transition.reload_game()


func _on_back_to_menu_pressed() -> void:
	_auto_return.stop()
	if _pending_ending == Endings.Kind.SECRET:
		await Transition.go_to_story(Endings.SECRET_ID)
	elif _pending_ending == Endings.Kind.ESCAPE:
		await Transition.go_to_story(Endings.ESCAPE_ID)
	else:
		await Transition.go_to_menu(Transition.MenuTarget.SONG_SELECTION)


func _resolve_pending_ending() -> Endings.Kind:
	var states: Array[Completion.State] = Endings.song_states(catalogue)
	var newly_secret: bool = (
		not GameData.ending_unlocked(Endings.SECRET_ID) and Endings.secret_threshold(states)
	)
	var newly_escape: bool = (
		not GameData.ending_unlocked(Endings.ESCAPE_ID) and Endings.escape_threshold(states)
	)
	if newly_secret:
		GameData.latch_ending_unlocked(Endings.SECRET_ID)
	if newly_escape:
		GameData.latch_ending_unlocked(Endings.ESCAPE_ID)
	if newly_secret:
		return Endings.Kind.SECRET
	if newly_escape:
		return Endings.Kind.ESCAPE
	return Endings.Kind.NONE


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
