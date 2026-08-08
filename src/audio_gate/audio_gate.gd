# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name AudioGate
extends CanvasLayer

# webAudioState() is defined in the web export shell (web/shell.html); it
# returns the AudioContext state, which is "running" when the browser will
# start Web Audio without a user gesture.
const AUDIO_STATE_CHECK: String = "webAudioState()"

@export var main_scene: PackedScene

var _handed_off: bool = false


func _ready() -> void:
	var is_web: bool = OS.has_feature(&"web")
	var audio_unlocked: bool = is_web and _is_audio_unlocked()
	if not is_web or audio_unlocked:
		_hand_off()


func _input(event: InputEvent) -> void:
	if _handed_off:
		return
	if event.is_pressed():
		_hand_off()


func _hand_off() -> void:
	if _handed_off:
		return
	if main_scene == null:
		printerr("AudioGate: main_scene is not set")
		return
	_handed_off = true
	get_tree().change_scene_to_packed.call_deferred(main_scene)


func _is_audio_unlocked() -> bool:
	var result: Variant = JavaScriptBridge.eval(AUDIO_STATE_CHECK, true)
	return result == "running"
