# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name SongRow
extends Button

@export var biome: BiomeEntry = null
@export var song: SongEntry = null

var ranks: Array[Rank.Level] = []:
	set(value):
		ranks = value
		if is_node_ready():
			_update_state()

@onready var _label: Label = $Stars/Label
@onready var _star: Star = $Stars/Star


func _ready() -> void:
	_update_state()


func _update_state() -> void:
	var state: Completion.State = Completion.from_ranks(ranks)
	_label.text = Completion.string(state)
	_label.add_theme_color_override(&"font_color", Completion.color(state))
	var best: Rank.Level = _best_rank()
	_star.rank = best
	_star.visible = best != Rank.Level.NONE


func _best_rank() -> Rank.Level:
	var best: Rank.Level = Rank.Level.NONE
	for rank: Rank.Level in ranks:
		if rank > best:
			best = rank
	return best
