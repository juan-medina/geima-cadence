# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Menu
extends PanelHost

const NOTIFICATION_DELAY: float = 2.0
const ATTRACT_DELAY: float = 300.0

var _attract_timer: Timer

@onready var _main_menu_panel: MainMenuPanel = $Center/MainMenuPanel
@onready var _song_selection_panel: SongSelectionPanel = $Center/SongSelectionPanel
@onready var _settings_panel: SettingsPanel = $Center/SettingsPanel
@onready var _about_panel: AboutPanel = $Center/AboutPanel
@onready var _story_panel: StoryPanel = $Center/StoryPanel
@onready var _cheat: AudioStreamPlayer2D = $Cheat


func _ready() -> void:
	get_tree().create_timer(NOTIFICATION_DELAY).timeout.connect(InputManager.enable_notifications)
	_show_first(_main_menu_panel)

	_attract_timer = Timer.new()
	_attract_timer.wait_time = ATTRACT_DELAY
	_attract_timer.one_shot = true
	_attract_timer.timeout.connect(_on_attract_timeout)
	add_child(_attract_timer)
	_attract_timer.start()


func _input(_event: InputEvent) -> void:
	if _attract_timer != null:
		_attract_timer.start()


func _on_attract_timeout() -> void:
	if _current != _main_menu_panel:
		return
	await Transition.go_to_story(&"intro")


func _on_play_requested() -> void:
	show_panel(_song_selection_panel)


func _on_story_requested() -> void:
	show_panel(_story_panel)


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
