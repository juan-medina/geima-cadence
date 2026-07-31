# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name DifficultyButton
extends Button

@export var custom_text: String = &"Difficulty"
@export var difficulty: Track.DifficultType = Track.DifficultType.EASY
@export var rank: Star.Rank = Star.Rank.NONE:
	set(value):
		rank = value
		if _star:
			_star.rank = value

@onready var _custom_text_label: Label = %CustomText
@onready var _star: Star = %Star


func _ready() -> void:
	_custom_text_label.text = custom_text
	_star.rank = rank
	_update_text_color()


func _on_focus_entered() -> void:
	_update_text_color()


func _on_focus_exited() -> void:
	_update_text_color()


func _on_toggled(_toggled_on: bool) -> void:
	_update_text_color()


func _update_text_color() -> void:
	if not is_node_ready():
		return
	if is_pressed() or has_focus():
		var focus_color: Color = get_theme_color(&"font_focus_color", &"Button")
		_custom_text_label.add_theme_color_override(&"font_color", focus_color)
	else:
		_custom_text_label.remove_theme_color_override(&"font_color")
