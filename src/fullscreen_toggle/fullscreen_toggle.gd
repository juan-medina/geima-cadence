# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

extends CanvasLayer

@onready var _fullscreen_button: TextureButton = $Fullscreen


func _ready() -> void:
	Options.fullscreen_changed.connect(_on_fullscreen_change)
	_on_fullscreen_change(Options.fullscreen)


func _exit_tree() -> void:
	Options.fullscreen_changed.disconnect(_on_fullscreen_change)


func _on_fullscreen_change(is_on: bool) -> void:
	_fullscreen_button.button_pressed = is_on


func _on_fullscreen_toggled(is_on: bool) -> void:
	Options.fullscreen = is_on


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_fullscreen"):
		Options.fullscreen = not Options.fullscreen


func _on_fullscreen_mouse_entered() -> void:
	_fullscreen_button.modulate.a = 0.5


func _on_fullscreen_mouse_exited() -> void:
	_fullscreen_button.modulate.a = 0.25
