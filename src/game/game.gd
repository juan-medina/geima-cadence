# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Game
extends Node2D

# Obstacles rest this far below the hero's ground line
const _OBSTACLE_OFFSET_Y: float = 22.0

@export var menu_scene: PackedScene = null

@onready var _track: Track = $Track
@onready var _biome: Biome = $Biome

@onready var _pause_overlay: PauseOverlay = $PauseOverlay

@onready var _camera: Camera2D = $Camera2D
@onready var _hero: Hero = $Hero
@onready var _hud: Hud = $Hud


func _ready() -> void:
	_hero.died.connect(_on_hero_died)
	_hero.dashed.connect(_biome.dash_burst)

	# Workaround for Godot 4 Camera2D not re-centering after the window resizes.
	get_tree().root.size_changed.connect(_on_window_resized)

	_prepare_biome()
	_track.begin()


func _prepare_biome() -> void:
	_biome.load()
	var ground_y: float = _biome.ground_y()
	_hero.set_ground_y(ground_y)
	_track.floor_y = ground_y + _OBSTACLE_OFFSET_Y


func _on_window_resized() -> void:
	_camera.enabled = false
	_camera.enabled = true
	_camera.force_update_scroll()


func _on_hero_died() -> void:
	# The player has finished dying, but the health bar may still be draining
	await _hud.health_settled()
	_pause_overlay.display()
