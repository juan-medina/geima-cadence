# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name MenuBackground
extends Node2D

@export var catalogue: Catalogue
@export var crossfade_time: float = 2.0
@export var display_time: float = 12.0
@export var scroll_speed: float = 100.0

var _current_scroll: float = 0.0
var _current_index: int = 0
var _is_a_active: bool = true
var _fade_tween: Tween

@onready var _biome_a: Biome = $BiomeA
@onready var _biome_b: Biome = $BiomeB


func _ready() -> void:
	if not catalogue or catalogue.biomes.is_empty():
		return

	_biome_a.modulate.a = 1.0
	_biome_b.modulate.a = 0.0

	_biome_a.load(catalogue.biomes[0])
	if catalogue.biomes.size() > 1:
		_biome_b.load(catalogue.biomes[1])

	_schedule_next_fade()


func _process(delta: float) -> void:
	_current_scroll -= scroll_speed * delta
	_biome_a.set_scroll(_current_scroll)
	_biome_b.set_scroll(_current_scroll)


func _schedule_next_fade() -> void:
	if catalogue.biomes.size() <= 1:
		return
	get_tree().create_timer(display_time).timeout.connect(_start_crossfade)


func _start_crossfade() -> void:
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()

	var active_biome: Biome = _biome_a if _is_a_active else _biome_b
	var hidden_biome: Biome = _biome_b if _is_a_active else _biome_a

	_fade_tween.tween_property(active_biome, ^"modulate:a", 0.0, crossfade_time)
	_fade_tween.parallel().tween_property(hidden_biome, ^"modulate:a", 1.0, crossfade_time)

	_fade_tween.finished.connect(_on_crossfade_finished)


func _on_crossfade_finished() -> void:
	_is_a_active = not _is_a_active

	_current_index = (_current_index + 1) % catalogue.biomes.size()
	var next_index: int = (_current_index + 1) % catalogue.biomes.size()

	var hidden_biome: Biome = _biome_b if _is_a_active else _biome_a
	hidden_biome.load(catalogue.biomes[next_index])

	_schedule_next_fade()
