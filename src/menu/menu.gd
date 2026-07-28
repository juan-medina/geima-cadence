# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Menu
extends CanvasLayer

@onready var _main_menu_panel: MainMenuPanel = $Center/MainMenuPanel
@onready var _stage_panel: StagePanel = $Center/StagePanel
@onready var _settings_panel: SettingsPanel = $Center/SettingsPanel
@onready var _about_panel: AboutPanel = $Center/AboutPanel
@onready var _cheat: AudioStreamPlayer2D = $Cheat


func _ready() -> void:
	_close_all()
	_main_menu_panel.open()


func _close_all() -> void:
	_main_menu_panel.close()
	_stage_panel.close()
	_settings_panel.close()
	_about_panel.close()


func _on_play_requested() -> void:
	_close_all()
	_stage_panel.open()


func _on_settings_requested() -> void:
	_close_all()
	_settings_panel.open()


func _on_about_requested() -> void:
	_close_all()
	_about_panel.open()


func _on_exit_requested() -> void:
	get_tree().quit()


func _on_panel_back_requested() -> void:
	_close_all()
	_main_menu_panel.open()


func _on_cheat_code_entered() -> void:
	Options.invincible = true
	_cheat.play()
