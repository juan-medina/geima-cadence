# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name MainMenuPanel
extends PanelContainer

signal play_requested
signal settings_requested
signal about_requested
signal exit_requested

@onready var _play_button: Button = $VBox/Play
@onready var _exit_button: Button = $VBox/Exit


func _ready() -> void:
	if OS.has_feature(&"web"):
		_exit_button.visible = false
	Audio.connect_menu_sounds(self)


func open() -> void:
	visible = true
	Audio.grab_focus_silent(_play_button)


func close() -> void:
	visible = false


func _on_play_pressed() -> void:
	play_requested.emit()


func _on_settings_pressed() -> void:
	settings_requested.emit()


func _on_about_pressed() -> void:
	about_requested.emit()


func _on_exit_pressed() -> void:
	exit_requested.emit()
