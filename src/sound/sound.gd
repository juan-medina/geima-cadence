# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

extends Node

const STEP_INTERVAL: float = 0.35
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

const EXPLOSION_1: AudioStream = preload("res://data/assets/sounds/01_Fire_explosion_01_small.wav")
const EXPLOSION_2: AudioStream = preload("res://data/assets/sounds/02_Fire_explosion_02_small.wav")
const FIRE_EXPLOSIONS: Array[AudioStream] = [EXPLOSION_1, EXPLOSION_2]

const SLIME: AudioStream = preload("res://data/assets/sounds/01_Slime_damage.wav")

const ASSASSIN_ATT_1: AudioStream = preload("res://data/assets/sounds/NinjaAssassin_Attack_1.wav")
const ASSASSIN_ATT_2: AudioStream = preload("res://data/assets/sounds/NinjaAssassin_Attack_2.wav")
const ASSASSIN_ATTACK: Array[AudioStream] = [ASSASSIN_ATT_1, ASSASSIN_ATT_2]

const ASSASSIN_DEATH: AudioStream = preload("res://data/assets/sounds/NinjaAssassin_Death.wav")

const GIANT_1: AudioStream = preload("res://data/assets/sounds/Giant_Wind_up_1.wav")
const GIANT_2: AudioStream = preload("res://data/assets/sounds/Giant_Wind_up_2.wav")
const GIANT_3: AudioStream = preload("res://data/assets/sounds/Giant_Wind_up_3.wav")
const GIANT_WIND_UPS: Array[AudioStream] = [GIANT_1, GIANT_2, GIANT_3]

const GIANT_DEATH_1: AudioStream = preload("res://data/assets/sounds/Giant_Death_1.wav")
const GIANT_DEATH_2: AudioStream = preload("res://data/assets/sounds/Giant_Death_2.wav")
const GIANT_DEATHS: Array[AudioStream] = [GIANT_DEATH_1, GIANT_DEATH_2]

const IMPACT_1: AudioStream = preload("res://data/assets/sounds/09_Impact_01.wav")
const IMPACT_2: AudioStream = preload("res://data/assets/sounds/10_Impact_02.wav")
const IMPACT_3: AudioStream = preload("res://data/assets/sounds/11_Impact_03.wav")
const IMPACT_4: AudioStream = preload("res://data/assets/sounds/12_Impact_04.wav")
const IMPACT_5: AudioStream = preload("res://data/assets/sounds/13_Impact_05.wav")
const IMPACTS: Array[AudioStream] = [IMPACT_1, IMPACT_2, IMPACT_3, IMPACT_4, IMPACT_5]

var _step_timer: Timer = null

var _step_sound: AudioStreamPlayer = null
var _jump_sound: AudioStreamPlayer = null
var _landing_sound: AudioStreamPlayer = null
var _dash_sound: AudioStreamPlayer = null
var _slide_sound: AudioStreamPlayer = null
var _slash_sound: AudioStreamPlayer = null
var _hit_sound: AudioStreamPlayer = null
var _die_sound: AudioStreamPlayer = null
var _fire_explosion_sound: AudioStreamPlayer = null
var _slime_sound: AudioStreamPlayer = null
var _assassin_att_sound: AudioStreamPlayer = null
var _assassin_death_sound: AudioStreamPlayer = null
var _giant_wind_up_sound: AudioStreamPlayer = null
var _giant_death_sound: AudioStreamPlayer = null
var _impact_sound: AudioStreamPlayer = null


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
	_fire_explosion_sound = create_random_sound(FIRE_EXPLOSIONS, 1.1)
	_slime_sound = create_sound(SLIME)
	_assassin_att_sound = create_random_sound(ASSASSIN_ATTACK, 1.1)
	_assassin_death_sound = create_sound(ASSASSIN_DEATH)
	_giant_wind_up_sound = create_random_sound(GIANT_WIND_UPS, 1.1)
	_giant_death_sound = create_random_sound(GIANT_DEATHS, 1.1)
	_impact_sound = create_random_sound(IMPACTS, 1.1)


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


func create_sound(stream: AudioStream, bus: StringName = &"SFX") -> AudioStreamPlayer:
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
	#_hit_sound.play()
	pass


func play_die() -> void:
	_die_sound.play()


func play_fire_explosion() -> void:
	_fire_explosion_sound.play()


func play_slime() -> void:
	_slime_sound.play()


func play_assassin_attack() -> void:
	_assassin_att_sound.play()


func play_assassin_death() -> void:
	_assassin_death_sound.play()


func play_giant_wind_up() -> void:
	_giant_wind_up_sound.play()


func play_giant_death() -> void:
	_giant_death_sound.play()


func play_impact() -> void:
	_impact_sound.play()
