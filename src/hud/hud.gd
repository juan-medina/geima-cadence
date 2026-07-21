# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Hud
extends CanvasLayer

const MAX_HEALTH: float = 100.0
const HIT_DAMAGE: float = 10.0
# Arcade damage trail: yellow drops instantly, the red ghost holds the old
# value for a beat and then drains down to meet it.
const TRAIL_HOLD_DURATION: float = 0.4
const TRAIL_DRAIN_DURATION: float = 0.25

@export var track: Track
@export var hero: Hero

var _health: float = MAX_HEALTH
var _trail_tween: Tween

@onready var _song_bar: TextureProgressBar = $SongPanel/SongBar
@onready var _health_bar: TextureProgressBar = $HealthPanel/HealthBar
@onready var _trail_bar: TextureProgressBar = $HealthPanel/TrailBar
@onready var _fullscreen_button: TextureButton = $Fullscreen


func _ready() -> void:
	if not track or not hero:
		push_error("Hud needs Track and Hero references!")
		return

	hero.hurt.connect(_on_hero_hurt)
	hero.stopped.connect(_on_hero_stopped)
	_health_bar.max_value = MAX_HEALTH
	_health_bar.value = _health
	_trail_bar.max_value = MAX_HEALTH
	_trail_bar.value = _health

	GlobalOptions.fullscreen_changed.connect(_on_fullscreen_change)
	_on_fullscreen_change(GlobalOptions.fullscreen)


func _exit_tree() -> void:
	GlobalOptions.fullscreen_changed.disconnect(_on_fullscreen_change)


func _process(_delta: float) -> void:
	if not track:
		return

	# The bar is the player's energy to reach the monolith: it fills as the run
	# advances, so it reads the track's progress and freezes when the run stops.
	_song_bar.value = track.get_progress()


func _on_hero_hurt() -> void:
	_set_health(_health - HIT_DAMAGE)


func _on_hero_stopped() -> void:
	# A fatal blow empties the bar outright, not just a single hit's worth.
	_set_health(0.0)


func _set_health(value: float) -> void:
	_health = clampf(value, 0.0, MAX_HEALTH)
	_health_bar.value = _health
	if _trail_tween:
		_trail_tween.kill()
	_trail_tween = create_tween()
	_trail_tween.tween_interval(TRAIL_HOLD_DURATION)
	_trail_tween.tween_property(_trail_bar, ^"value", _health, TRAIL_DRAIN_DURATION)


func _on_fullscreen_toggled(is_on: bool) -> void:
	GlobalOptions.fullscreen = is_on


func _on_fullscreen_change(is_on: bool) -> void:
	_fullscreen_button.button_pressed = is_on
