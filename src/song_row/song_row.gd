# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name SongRow
extends Button

@export var biome: BiomeEntry = null
@export var song: SongEntry = null
@export var stars: int = 0:
	set(value):
		stars = value
		if is_node_ready():
			_update_stars_label()

@onready var _stars_label: Label = $Stars/Label


func _ready() -> void:
	_update_stars_label()


func _update_stars_label() -> void:
	_stars_label.text = &"%d / 3" % stars
