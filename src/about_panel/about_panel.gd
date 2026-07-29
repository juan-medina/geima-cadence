# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name AboutPanel
extends PanelContainer

signal back_requested

const ABOUT_PATH: String = "res://data/assets/about.txt"

@onready var _back_button: Button = $VBox/Back
@onready var _about_text: BigTextPanel = $VBox/AboutText


func _ready() -> void:
	Audio.connect_menu_sounds(self)
	_about_text.load_file(ABOUT_PATH)


func open() -> void:
	visible = true
	_back_button.grab_focus()


func close() -> void:
	visible = false


func _on_back_pressed() -> void:
	back_requested.emit()
