# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Hud
extends CanvasLayer

# Arcade damage trail: yellow drops instantly, the red ghost holds the old
# value for a beat and then drains down to meet it.
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


# Returns once the trail has caught up with the bar. The drain outlasts the death
# animation on a big hit and lands first on a small one, so the caller waits on
# this rather than assuming either order.
func health_settled() -> void:
	if _trail_tween and _trail_tween.is_running():
		await _trail_tween.finished


func _on_health_changed(current: float) -> void:
	# The bar just mirrors the hero's health: yellow snaps to the new value, the
	# red trail holds a beat then drains to meet it. A fatal hit sends 0, so the
	# bar empties here too — no special death case needed.
	_health_bar.value = current
	if _trail_tween:
		_trail_tween.kill()
	_trail_tween = create_tween()
	_trail_tween.tween_interval(TRAIL_HOLD_DURATION)
	_trail_tween.tween_property(_trail_bar, ^"value", current, TRAIL_DRAIN_DURATION)


func _on_fullscreen_toggled(is_on: bool) -> void:
	GlobalOptions.fullscreen = is_on


func _on_fullscreen_change(is_on: bool) -> void:
	_fullscreen_button.button_pressed = is_on
