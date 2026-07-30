# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Menu
extends PanelHost

@onready var _main_menu_panel: MainMenuPanel = $Center/MainMenuPanel
@onready var _biome_carousel_panel: BiomeCarouselPanel = $Center/BiomeCarouselPanel
@onready var _settings_panel: SettingsPanel = $Center/SettingsPanel
@onready var _about_panel: AboutPanel = $Center/AboutPanel
@onready var _cheat: AudioStreamPlayer2D = $Cheat


func _ready() -> void:
	_show_first(_main_menu_panel)


func _on_play_requested() -> void:
	show_panel(_biome_carousel_panel)


func _on_settings_requested() -> void:
	show_panel(_settings_panel)


func _on_about_requested() -> void:
	show_panel(_about_panel)


func _on_exit_requested() -> void:
	get_tree().quit()


func _on_panel_back_requested() -> void:
	show_panel(_main_menu_panel)


func _on_cheat_code_entered() -> void:
	Options.invincible = true
	_cheat.play()
