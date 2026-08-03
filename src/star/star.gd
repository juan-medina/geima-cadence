# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Star
extends Control

const _GOLD: Color = Color.GOLD
const _BRONZE: Color = Color(0.65, 0.4, 0.15)
const _EMPTY: Color = Color(0.25, 0.25, 0.3)
const _LETTER: Color = Color(0.2, 0.12, 0.1)

@export var rank: Rank.Level = Rank.Level.NONE:
	set(value):
		rank = value
		_refresh()

@onready var _icon: TextureRect = %Icon
@onready var _label: Label = %Label


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	# The setter can fire before the node is in the tree (e.g. assigned from a
	# scene), so bail until the child refs exist; _ready re-runs it.
	if not is_node_ready():
		return
	_label.add_theme_color_override(&"font_color", _LETTER)
	_label.text = Rank.string(rank)
	_icon.modulate = Rank.color(rank)
