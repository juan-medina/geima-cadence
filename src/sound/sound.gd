# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

extends Node

const STEP_INTERVAL: float = 0.25
const STEP_1: AudioStream = preload("res://data/assets/sounds/07_Step_rock_01.wav")
const STEP_2: AudioStream = preload("res://data/assets/sounds/08_Step_rock_02.wav")
const STEP_3: AudioStream = preload("res://data/assets/sounds/09_Step_rock_03.wav")
const STEPS: Array[AudioStream] = [STEP_1, STEP_2, STEP_3]

const JUMP_1: AudioStream = preload("res://data/assets/sounds/28_Jump_01.wav")
const JUMP_2: AudioStream = preload("res://data/assets/sounds/29_Jump_02.wav")
const JUMP_3: AudioStream = preload("res://data/assets/sounds/30_Jump_03.wav")
const JUMP_4: AudioStream = preload("res://data/assets/sounds/31_Jump_04.wav")
const JUMPS: Array[AudioStream] = [JUMP_1, JUMP_2, JUMP_3, JUMP_4]

const LANDING_1: AudioStream = preload("res://data/assets/sounds/45_Landing_01.wav")
const LANDING_2: AudioStream = preload("res://data/assets/sounds/46_Landing_02.wav")
const LANDING_3: AudioStream = preload("res://data/assets/sounds/47_Landing_03.wav")
const LANDINGS: Array[AudioStream] = [LANDING_1, LANDING_2, LANDING_3]

const DASH: AudioStream = preload("res://data/assets/sounds/66_Dash_evade_02.wav")

const SLIDE: AudioStream = preload("res://data/assets/sounds/19_Slide_01.wav")

const SLASH_1: AudioStream = preload("res://data/assets/sounds/31_swoosh_sword_1.wav")
const SLASH_2: AudioStream = preload("res://data/assets/sounds/32_swoosh_sword_2.wav")
const SLASH_3: AudioStream = preload("res://data/assets/sounds/33_swoosh_sword_3.wav")

const SLASHES: Array[AudioStream] = [SLASH_1, SLASH_2, SLASH_3]

const HIT_1: AudioStream = preload("res://data/assets/sounds/62_Get_hit_01.wav")
const HIT_2: AudioStream = preload("res://data/assets/sounds/63_Get_hit_02.wav")
const HITS: Array[AudioStream] = [HIT_1, HIT_2]

const DIE: AudioStream = preload("res://data/assets/sounds/68_Die_01.wav")

var _step_timer: Timer = null

var _step_sound: AudioStreamPlayer = null
var _jump_sound: AudioStreamPlayer = null
var _landing_sound: AudioStreamPlayer = null
var _dash_sound: AudioStreamPlayer = null
var _slide_sound: AudioStreamPlayer = null
var _slash_sound: AudioStreamPlayer = null
var _hit_sound: AudioStreamPlayer = null
var _die_sound: AudioStreamPlayer = null


func _ready() -> void:
	_step_timer = Timer.new()
	_step_timer.wait_time = STEP_INTERVAL
	_step_timer.one_shot = false
	_step_timer.timeout.connect(_on_step_timer_timeout)
	add_child(_step_timer)

	_step_sound = create_random_sound(STEPS, 1.1)

	_jump_sound = create_random_sound(JUMPS, 1.1)
	_landing_sound = create_random_sound(LANDINGS, 1.1)
	_dash_sound = create_sound(DASH)
	_slide_sound = create_sound(SLIDE)
	_slash_sound = create_random_sound(SLASHES, 1.1)
	_hit_sound = create_random_sound(HITS, 1.1)
	_die_sound = create_sound(DIE)


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


func create_sound(stream: AudioStream) -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = stream
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
	_step_sound.play()


func play_jump() -> void:
	_jump_sound.play()


func play_landing() -> void:
	_landing_sound.play()


func play_dash() -> void:
	_dash_sound.play()


func play_slide() -> void:
	_slide_sound.play()


func play_slash() -> void:
	_slash_sound.play()


func play_hit() -> void:
	_hit_sound.play()


func play_die() -> void:
	_die_sound.play()
