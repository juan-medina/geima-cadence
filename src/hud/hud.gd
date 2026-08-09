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
@onready var _bar_spark: CPUParticles2D = $BarSpark


func _ready() -> void:
	if not track or not hero:
		printerr(&"Hud needs Track and Hero references!")
		Transition.fatal_error(&"Could not start the game")
		return

	hero.health_changed.connect(_on_health_changed)
	_health_bar.max_value = hero.max_health
	_health_bar.value = hero.health
	_trail_bar.max_value = hero.max_health
	_trail_bar.value = hero.health


func _process(_delta: float) -> void:
	# the track indicates the progress
	_song_bar.value = track.get_progress()

	var progress: float = _song_bar.value / _song_bar.max_value
	var bar_left: float = _song_bar.global_position.x
	var bar_width: float = _song_bar.size.x
	var bar_mid_y: float = _song_bar.global_position.y + _song_bar.size.y / 2.0
	_bar_spark.position = Vector2(bar_left + progress * bar_width, bar_mid_y)


func _on_health_changed(current: float) -> void:
	_health_bar.value = current
	if _trail_tween:
		_trail_tween.kill()
	_trail_tween = create_tween()
	_trail_tween.tween_interval(TRAIL_HOLD_DURATION)
	_trail_tween.tween_property(_trail_bar, ^"value", current, TRAIL_DRAIN_DURATION)


func await_health_settled() -> void:
	if _trail_tween and _trail_tween.is_running():
		await _trail_tween.finished
