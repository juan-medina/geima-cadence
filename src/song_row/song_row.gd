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
	var state: Completion.State = Completion.from(ranks)
	_label.add_theme_color_override(&"font_color", Completion.color(state))
	_star.visible = state == Completion.State.MASTERING or state == Completion.State.MASTERED

	# The count is a row choice: for MASTERING we show progress toward the S set
	# instead of the plain word.
	if state == Completion.State.MASTERING:
		_label.text = &"%d / %d" % [_s_count(), ranks.size()]
	else:
		_label.text = Completion.string(state)


func _s_count() -> int:
	var count: int = 0
	for rank: Rank.Level in ranks:
		if rank == Rank.Level.S:
			count += 1
	return count
