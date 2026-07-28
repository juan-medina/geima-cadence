# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name PauseOverlay
extends CanvasLayer

var _can_resume: bool = false

@onready var _pause_panel: PausePanel = $Center/PausePanel
@onready var _settings_panel: SettingsPanel = $Center/SettingsPanel


func display() -> void:
	_open_pause(false)


func _open_pause(can_resume: bool) -> void:
	_can_resume = can_resume
	_settings_panel.close()
	_pause_panel.open(can_resume)
	visible = true
	get_tree().paused = true


func _close() -> void:
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
	_settings_panel.open()
	_pause_panel.close()


func _on_settings_panel_back_requested() -> void:
	_settings_panel.close()
	_pause_panel.open(_can_resume)
