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
	_label.text = _text(state)
	_label.add_theme_color_override(&"font_color", Completion.color(state))
	_star.visible = state == Completion.State.MASTERING or state == Completion.State.MASTERED


# Escape is binary, so only mastering carries a count toward the full S set.
func _text(state: Completion.State) -> String:
	if state == Completion.State.MASTERING:
		return &"%s %d / %d" % [Completion.string(state), _mastered_count(), ranks.size()]
	return Completion.string(state)


func _mastered_count() -> int:
	var count: int = 0
	for rank: Rank.Level in ranks:
		if rank == Rank.Level.S:
			count += 1
	return count
