# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name PauseOverlay
extends PanelHost

var _can_resume: bool = false

@onready var _pause_panel: PausePanel = $Center/PausePanel
@onready var _settings_panel: SettingsPanel = $Center/SettingsPanel
@onready var _win_panel: WinPanel = $Center/WinPanel

func display() -> void:
	_open_pause(false)


func _open_pause(can_resume: bool) -> void:
	_can_resume = can_resume
	get_tree().paused = true
	_settings_panel.visible = false
	_pause_panel.configure(can_resume)
	set_host_alpha(0.0)
	_show_first(_pause_panel)
	visible = true
	fade_host(1.0)

func _open_win(rank: Rank.Level) -> void:
	get_tree().paused = true
	_win_panel.rank = rank
	_win_panel.visible = false
	_show_first(_win_panel)
	visible = true
	fade_host(1.0)

func _close() -> void:
	fade_host(0.0).finished.connect(_on_close_finished)


func _on_close_finished() -> void:
	visible = false
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"pause"):
		return
	if not visible:
		Audio.play_pause()
		_open_pause(true)
	elif not _can_resume:
		await Transition.go_to_menu()


func _on_resume_requested() -> void:
	_close()


func _on_pause_panel_settings_requested() -> void:
	show_panel(_settings_panel)


func _on_settings_panel_back_requested() -> void:
	show_panel(_pause_panel)
