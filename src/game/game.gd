# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Game
extends Node2D

# Obstacles rest this far below the hero's ground line
const _OBSTACLE_OFFSET_Y: float = 22.0

@export var catalogue: Catalogue

@onready var _track: Track = $Track
@onready var _biome: Biome = $Biome

@onready var _pause_overlay: PauseOverlay = $PauseOverlay

@onready var _camera: Camera2D = $Camera2D
@onready var _hero: Hero = $Hero
@onready var _hud: Hud = $Hud

@onready var _game_over: AudioStreamPlayer = $GameOver
@onready var _game_win: AudioStreamPlayer = $GameWin


func _ready() -> void:
	_hero.died.connect(_on_hero_died)

	# disable the dash burst effect for now, we may remove it entirely
	# _hero.dashed.connect(_biome.dash_burst)

	# Workaround for Godot 4 Camera2D not re-centering after the window resizes.
	get_tree().root.size_changed.connect(_on_window_resized)

	_track.scrolled.connect(_biome.set_scroll)

	_prepare_biome()
	_track.begin()


func _prepare_biome() -> void:
	var biome_entry: BiomeEntry = catalogue.get_biome_for_song(GameData.last_song_id)
	if not biome_entry:
		printerr(&"No biome found for song: " + GameData.last_song_id + &"!")
		get_tree().quit()
		return
	_biome.load(biome_entry)
	var ground_y: float = _biome.ground_y()
	_hero.set_ground_y(ground_y)
	_track.floor_y = ground_y + _OBSTACLE_OFFSET_Y


func _on_window_resized() -> void:
	_camera.enabled = false
	_camera.enabled = true
	_camera.force_update_scroll()


func _on_hero_died() -> void:
	_pause_overlay.set_process_unhandled_input(false)

	_track.stop_music()
	_game_over.play()
	await _hud.await_health_settled()

	_pause_overlay.display()
	_pause_overlay.set_process_unhandled_input(true)


func _on_track_victory_reached() -> void:
	_pause_overlay.set_process_unhandled_input(false)

	_hero.vanish()
	await _hero.vanished

	_open_pause_win_overlay()
	_pause_overlay.set_process_unhandled_input(true)


func _open_pause_win_overlay() -> void:
	_game_win.play()
	var rank: Rank.Level = Rank.from_health_percentage(_hero.health_percentage)
	GameData.set_star_record(GameData.last_song_id, GameData.difficulty, rank)
	_pause_overlay._open_win(rank)
