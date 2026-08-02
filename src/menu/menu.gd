# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Menu
extends PanelHost

const NOTIFICATION_DELAY: float = 2.0

@onready var _main_menu_panel: MainMenuPanel = $Center/MainMenuPanel
@onready var _song_selection_panel: SongSelectionPanel = $Center/SongSelectionPanel
@onready var _settings_panel: SettingsPanel = $Center/SettingsPanel
@onready var _about_panel: AboutPanel = $Center/AboutPanel
@onready var _cheat: AudioStreamPlayer2D = $Cheat


func _ready() -> void:
	get_tree().create_timer(NOTIFICATION_DELAY).timeout.connect(InputManager.enable_notifications)
	_show_first(_main_menu_panel)


func _on_play_requested() -> void:
	show_panel(_song_selection_panel)


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
