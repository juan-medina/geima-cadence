# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

extends Node

const STEP_1: AudioStream = preload("res://data/assets/sounds/07_Step_rock_01.wav")
const STEP_2: AudioStream = preload("res://data/assets/sounds/08_Step_rock_02.wav")
const STEP_3: AudioStream = preload("res://data/assets/sounds/09_Step_rock_03.wav")
const STEPS: Array[AudioStream] = [STEP_1, STEP_2, STEP_3]

const STEP_INTERVAL: float = 0.25

const JUMP_1: AudioStream = preload("res://data/assets/sounds/28_Jump_01.wav")
const JUMP_2: AudioStream = preload("res://data/assets/sounds/29_Jump_02.wav")
const JUMP_3: AudioStream = preload("res://data/assets/sounds/30_Jump_03.wav")
const JUMP_4: AudioStream = preload("res://data/assets/sounds/31_Jump_04.wav")
const JUMPS: Array[AudioStream] = [JUMP_1, JUMP_2, JUMP_3, JUMP_4]

var _step_sound: AudioStreamPlayer = null
var _step_timer: Timer = null

var _jump_sound: AudioStreamPlayer = null


func _ready() -> void:
	_step_sound = create_random_sound(STEPS, 1.1)

	_step_timer = Timer.new()
	_step_timer.wait_time = STEP_INTERVAL
	_step_timer.one_shot = false
	_step_timer.timeout.connect(_on_step_timer_timeout)
	add_child(_step_timer)

	_jump_sound = create_random_sound(JUMPS, 1.1)


func create_random_sound(streams: Array[AudioStream], pitch: float) -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	var randomizer: AudioStreamRandomizer = AudioStreamRandomizer.new()

	for stream: AudioStream in streams:
		randomizer.add_stream(-1, stream)

	randomizer.playback_mode = AudioStreamRandomizer.PLAYBACK_RANDOM_NO_REPEATS
	randomizer.random_pitch = pitch

	player.stream = randomizer
	player.bus = &"SFX"
	add_child(player)
	return player


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


func play_jump() -> void:
	_jump_sound.play()
