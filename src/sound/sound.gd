# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

extends Node

const STEP_1: AudioStream = preload("res://data/assets/sounds/07_Step_rock_01.wav")
const STEP_2: AudioStream = preload("res://data/assets/sounds/08_Step_rock_02.wav")
const STEP_3: AudioStream = preload("res://data/assets/sounds/09_Step_rock_03.wav")
const STEP_INTERVAL: float = 0.25

var _step_sound: AudioStreamPlayer = null
var _step_timer: Timer = null


func _ready() -> void:
	_step_sound = AudioStreamPlayer.new()

	var randomizer: AudioStreamRandomizer = AudioStreamRandomizer.new()
	randomizer.add_stream(-1, STEP_1)
	randomizer.add_stream(-1, STEP_2)
	randomizer.add_stream(-1, STEP_3)

	randomizer.playback_mode = AudioStreamRandomizer.PLAYBACK_RANDOM_NO_REPEATS
	randomizer.random_pitch = 1.1

	_step_sound.stream = randomizer
	_step_sound.bus = "SFX"
	add_child(_step_sound)

	_step_timer = Timer.new()
	_step_timer.wait_time = STEP_INTERVAL
	_step_timer.one_shot = false
	_step_timer.timeout.connect(_on_step_timer_timeout)
	add_child(_step_timer)


func start_footsteps() -> void:
	if _step_timer.is_stopped():
		_step_sound.play()
		_step_timer.start()


func stop_footsteps() -> void:
	if not _step_timer.is_stopped():
		_step_timer.stop()


func _on_step_timer_timeout() -> void:
	#if not _step_sound.playing:
	_step_sound.play()
