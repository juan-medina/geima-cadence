# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name PauseOverlay
extends CanvasLayer

var _can_resume: bool = false

@onready var _pause_panel: PausePanel = $Center/PausePanel


func display() -> void:
	_open_pause(false)


func _open_pause(can_resume: bool) -> void:
	_can_resume = can_resume
	_pause_panel.open(can_resume)
	visible = true
	get_tree().paused = true


func _close() -> void:
	visible = false
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		if visible:
			if _can_resume:
				_close()
			else:
				await Transition.go_to_menu()
		else:
			_open_pause(true)


func _on_resume_requested() -> void:
	_close()
