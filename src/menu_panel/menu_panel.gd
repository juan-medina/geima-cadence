# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name MenuPanel
extends PanelContainer


func _ready() -> void:
	Audio.connect_menu_sounds(self)


func first_focus_control() -> Control:
	return null
