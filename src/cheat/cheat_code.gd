# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name CheatCode
extends Node

## Emitted once the full sequence has been entered in order.
signal entered

# Up, Up, Down, Down, Left, Right, Left, Right, B, A. The directions reuse the
# gameplay actions, so arrow keys and the d-pad both feed them; B and A have
# their own actions, so keyboard (the B and A keys) and gamepad (the B and A
# face buttons) share one sequence.
const _SEQUENCE: Array[StringName] = [
	&"up",
	&"up",
	&"down",
	&"down",
	&"left",
	&"right",
	&"left",
	&"right",
	&"cheat_b",
	&"cheat_a",
]

# How far into the sequence the player has matched so far.
var _index: int = 0


func _input(event: InputEvent) -> void:
	# Only presses count; echoes (a held key) and releases are ignored so a held
	# direction cannot race through the sequence.
	if not event.is_pressed() or event.is_echo():
		return

	if event.is_action_pressed(_SEQUENCE[_index]):
		_index += 1
		# on swallow ui_accept, the final step so we don't "accept" a menu button
		if event.is_action_pressed(&"ui_accept") and _index == _SEQUENCE.size():
			get_viewport().set_input_as_handled()
		if _index == _SEQUENCE.size():
			_index = 0
			entered.emit()
	elif event.is_action_pressed(_SEQUENCE[0]):
		# A wrong press that is itself a fresh start counts as the first step.
		_index = 1
	else:
		_index = 0
