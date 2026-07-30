# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name SongRow
extends Button

const STAR_EARNED: Color = Color.WHITE
const STAR_MISSING: Color = Color(0.4, 0.4, 0.4)
const FLASH_MIN_ALPHA: float = 0.25
const FLASH_TIME: float = 0.5

var _song: SongEntry
var _flash_tween: Tween

@onready var _song_name: Label = %SongName
@onready var _bpm: Label = %Bpm
@onready var _stars: HBoxContainer = %Stars
@onready var _play: Label = %Play
@onready var _highlight: Panel = %Highlight


func setup(song: SongEntry) -> void:
	_song = song
	_song_name.text = song.name
	_bpm.text = "%d BPM" % song.bpm
	# Earned stars come from the (not yet built) score store; none for now.
	_set_stars(0)


func song() -> SongEntry:
	return _song


func _set_stars(earned: int) -> void:
	for i: int in _stars.get_child_count():
		var star: TextureRect = _stars.get_child(i) as TextureRect
		star.modulate = STAR_EARNED if i < earned else STAR_MISSING


# The panel focuses the first row with signals blocked, so selection is driven
# off the focus notification rather than the focus_entered signal. This fires for
# keyboard, controller, and mouse hover (hover grabs focus) alike.
func _notification(what: int) -> void:
	if what == NOTIFICATION_FOCUS_ENTER:
		_set_selected(true)
	elif what == NOTIFICATION_FOCUS_EXIT:
		_set_selected(false)


func _set_selected(selected: bool) -> void:
	_highlight.visible = selected
	_flash_play(selected)


func _flash_play(active: bool) -> void:
	# The label always keeps its slot (so the row never reflows); only its alpha
	# changes, pulsing while selected and fully transparent otherwise.
	if _flash_tween != null:
		_flash_tween.kill()
	if not active:
		_play.modulate.a = 0.0
		return
	_play.modulate.a = 1.0
	_flash_tween = create_tween().set_loops()
	_flash_tween.tween_property(_play, ^"modulate:a", FLASH_MIN_ALPHA, FLASH_TIME)
	_flash_tween.tween_property(_play, ^"modulate:a", 1.0, FLASH_TIME)
