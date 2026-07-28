# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name AboutPanel
extends PanelContainer

signal back_requested

@onready var _back_button: Button = $VBox/Back


func _ready() -> void:
	Audio.connect_menu_sounds(self)


func open() -> void:
	visible = true
	_back_button.grab_focus()


func close() -> void:
	visible = false


func _on_back_pressed() -> void:
	back_requested.emit()
