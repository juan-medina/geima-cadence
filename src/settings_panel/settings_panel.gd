# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name SettingsPanel
extends PanelContainer

signal back_requested


@onready var _back_button: Button = $VBox/Back
@onready var _fullscreen_check: CheckButton = $VBox/Fullscreen


func _ready() -> void:
	Options.fullscreen_changed.connect(_on_fullscreen_changed)
	_on_fullscreen_changed(Options.fullscreen)


func _exit_tree() -> void:
	Options.fullscreen_changed.disconnect(_on_fullscreen_changed)


func open() -> void:
	visible = true
	_back_button.grab_focus()


func close() -> void:
	visible = false


func _on_fullscreen_changed(is_on: bool) -> void:
	_fullscreen_check.button_pressed = is_on


func _on_fullscreen_toggled(is_on: bool) -> void:
	Options.fullscreen = is_on


func _on_back_pressed() -> void:
	back_requested.emit()
