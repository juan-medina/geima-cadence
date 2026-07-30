# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

extends Node

var _suppress_hover: bool = false

@onready var _hover: AudioStreamPlayer = $Hover
@onready var _click: AudioStreamPlayer = $Click
@onready var _return: AudioStreamPlayer = $Return
@onready var _start: AudioStreamPlayer = $Start
@onready var _pause: AudioStreamPlayer = $Pause


func play_hover() -> void:
	if _suppress_hover:
		return
	_hover.play()


func play_click() -> void:
	_click.play()


func slider_change(_value: float) -> void:
	_click.play()


func play_return() -> void:
	_return.play()


func play_start() -> void:
	_start.play()


func play_pause() -> void:
	_pause.play()


func grab_focus_silent(control: Control) -> void:
	# Focus without the hover sound. focus_entered still fires synchronously,
	# so focus-driven visuals react normally — only the sound is skipped.
	_suppress_hover = true
	control.grab_focus()
	_suppress_hover = false

func connect_menu_sounds(root: Node) -> void:
	for child: Node in root.get_children():
		var control: Control = child as Control
		if control:
			connect_sound(control)
			connect_menu_sounds(control)


func connect_sound(control: Control) -> void:
	var button: BaseButton = control as BaseButton
	if button:
		_connect_button(button)
		return

	var slider: Slider = control as Slider
	if slider:
		_connect_slider(slider)
		return

	_connect_focus(control)


func _connect_button(button: BaseButton) -> void:
	_connect_focus(button)

	if button.is_in_group(&"ui_return"):
		button.pressed.connect(play_return)
	elif button.is_in_group(&"ui_start"):
		button.pressed.connect(play_start)
	else:
		button.pressed.connect(play_click)


func _connect_slider(slider: Slider) -> void:
	slider.mouse_entered.connect(slider.grab_focus)
	slider.focus_entered.connect(play_hover)
	slider.value_changed.connect(slider_change)


func _connect_focus(control: Control) -> void:
	if control.focus_mode != Control.FOCUS_NONE:
		control.mouse_entered.connect(control.grab_focus)
	control.focus_entered.connect(play_hover)
