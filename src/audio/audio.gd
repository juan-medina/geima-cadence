# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

extends Node

@onready var _hover: AudioStreamPlayer = $Hover
@onready var _click: AudioStreamPlayer = $Click
@onready var _return: AudioStreamPlayer = $Return
@onready var _start: AudioStreamPlayer = $Start
@onready var _pause: AudioStreamPlayer = $Pause


func play_hover() -> void:
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


# focus_entered is emitted synchronously inside grab_focus(), so blocking
# signals around the call suppresses the hover sound this is used to
# focus the first control in the menus without emitting a sound
func grab_focus_silent(control: Control) -> void:
	control.set_block_signals(true)
	control.grab_focus()
	control.set_block_signals(false)


func connect_menu_sounds(root: Node) -> void:
	for child: Node in root.get_children():
		var control: Control = child as Control
		if control:
			connect_sound(control)
			connect_menu_sounds(control)


func connect_sound(control: Control) -> void:
	var button: BaseButton = control as Button
	if button:
		button.mouse_entered.connect(button.grab_focus)
		button.focus_entered.connect(play_hover)
		if button.is_in_group(&"ui_return"):
			button.pressed.connect(play_return)
		elif button.is_in_group(&"ui_start"):
			button.pressed.connect(play_start)
		else:
			button.pressed.connect(play_click)
		return

	var slider: Slider = control as Slider
	if slider:
		slider.mouse_entered.connect(slider.grab_focus)
		slider.focus_entered.connect(play_hover)
		slider.value_changed.connect(slider_change)
