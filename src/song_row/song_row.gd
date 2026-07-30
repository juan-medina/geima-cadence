# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name SongRow
extends Button

const STAR_EARNED: Color = Color.WHITE
const STAR_MISSING: Color = Color(0.4, 0.4, 0.4)
const BREATH_MIN_ALPHA: float = 0.25
const BREATH_TIME: float = 0.5

var _song: SongEntry
var _breath_tween: Tween

@onready var _song_name: Label = %SongName
@onready var _bpm: Label = %Bpm
@onready var _stars: HBoxContainer = %Stars
@onready var _play: Label = %Play
@onready var _highlight: Panel = %Highlight


func setup(song: SongEntry) -> void:
	_song = song
	_song_name.text = song.name
	_bpm.text = "%d BPM" % song.bpm
	_set_stars(0)


func song_entry() -> SongEntry:
	return _song


func _set_stars(earned: int) -> void:
	for i: int in _stars.get_child_count():
		var star: TextureRect = _stars.get_child(i) as TextureRect
		star.modulate = STAR_EARNED if i < earned else STAR_MISSING


func _notification(what: int) -> void:
	if what == NOTIFICATION_FOCUS_ENTER:
		_set_selected(true)
	elif what == NOTIFICATION_FOCUS_EXIT:
		_set_selected(false)


func _set_selected(selected: bool) -> void:
	if _breath_tween != null:
		_breath_tween.kill()
	_highlight.visible = selected

	_play.modulate.a = 1.0 if selected else 0.0
	if not selected:
		return

	_highlight.modulate.a = 1.0
	_breath_tween = create_tween().set_loops()
	_breath_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_breath_tween.tween_property(_highlight, ^"modulate:a", BREATH_MIN_ALPHA, BREATH_TIME)
	_breath_tween.tween_property(_highlight, ^"modulate:a", 1.0, BREATH_TIME)
