# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Hud
extends CanvasLayer

# Arcade damage trail: yellow drops instantly, the red ghost holds the old
const TRAIL_HOLD_DURATION: float = 0.4
const TRAIL_DRAIN_DURATION: float = 0.25

@export var track: Track
@export var hero: Hero

var _trail_tween: Tween

@onready var _song_bar: TextureProgressBar = $SongFrame/SongPanel/SongBar
@onready var _health_bar: TextureProgressBar = $HealthFrame/HealthPanel/HealthBar
@onready var _trail_bar: TextureProgressBar = $HealthFrame/HealthPanel/TrailBar
@onready var _fullscreen_button: TextureButton = $Fullscreen


func _ready() -> void:
	if not track or not hero:
		push_error("Hud needs Track and Hero references!")
		return

	hero.health_changed.connect(_on_health_changed)
	_health_bar.max_value = hero.max_health
	_health_bar.value = hero.health
	_trail_bar.max_value = hero.max_health
	_trail_bar.value = hero.health

	Options.fullscreen_changed.connect(_on_fullscreen_change)
	_on_fullscreen_change(Options.fullscreen)


func _exit_tree() -> void:
	Options.fullscreen_changed.disconnect(_on_fullscreen_change)


func _process(_delta: float) -> void:
	if not track:
		return
	# the track indicates the progress
	_song_bar.value = track.get_progress()


func health_settled() -> void:
	if _trail_tween and _trail_tween.is_running():
		await _trail_tween.finished


func _on_health_changed(current: float) -> void:
	_health_bar.value = current
	if _trail_tween:
		_trail_tween.kill()
	_trail_tween = create_tween()
	_trail_tween.tween_interval(TRAIL_HOLD_DURATION)
	_trail_tween.tween_property(_trail_bar, ^"value", current, TRAIL_DRAIN_DURATION)


func _on_fullscreen_toggled(is_on: bool) -> void:
	Options.fullscreen = is_on


func _on_fullscreen_change(is_on: bool) -> void:
	_fullscreen_button.button_pressed = is_on
