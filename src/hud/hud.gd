# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Hud
extends CanvasLayer

signal health_settled

# Arcade damage trail: yellow drops instantly, the red ghost holds the old
const TRAIL_HOLD_DURATION: float = 0.4
const TRAIL_DRAIN_DURATION: float = 0.25

@export var track: Track
@export var hero: Hero

var _trail_tween: Tween

@onready var _song_bar: TextureProgressBar = $SongFrame/SongPanel/SongBar
@onready var _health_bar: TextureProgressBar = $HealthFrame/HealthPanel/HealthBar
@onready var _trail_bar: TextureProgressBar = $HealthFrame/HealthPanel/TrailBar


func _ready() -> void:
	if not track or not hero:
		printerr(&"Hud needs Track and Hero references!")
		get_tree().quit()
		return

	hero.health_changed.connect(_on_health_changed)
	_health_bar.max_value = hero.max_health
	_health_bar.value = hero.health
	_trail_bar.max_value = hero.max_health
	_trail_bar.value = hero.health


func _process(_delta: float) -> void:
	if not track:
		return
	# the track indicates the progress
	_song_bar.value = track.get_progress()


func _on_health_changed(current: float) -> void:
	_health_bar.value = current
	if _trail_tween:
		_trail_tween.kill()
	_trail_tween = create_tween()
	_trail_tween.tween_interval(TRAIL_HOLD_DURATION)
	_trail_tween.tween_property(_trail_bar, ^"value", current, TRAIL_DRAIN_DURATION)
	_trail_tween.tween_callback(health_settled.emit)
