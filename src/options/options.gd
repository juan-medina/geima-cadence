# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Options
extends Node

const CONFIG_PATH: String = "user://options.cfg"
const SECTION_DISPLAY: StringName = &"display"
const SECTION_AUDIO: StringName = &"audio"
const SECTION_EULA: StringName = &"eula"
const SECTION_GAMEPLAY: StringName = &"gameplay"

const DEFAULT_FULLSCREEN: bool = true
const DEFAULT_MASTER_VOLUME: float = 1.0
const DEFAULT_MUSIC_VOLUME: float = 0.5
const DEFAULT_SFX_VOLUME: float = 0.5
const DEFAULT_EULA_VERSION: StringName = ""

var fullscreen: bool = DEFAULT_FULLSCREEN:
	get():
		return fullscreen
	set(value):
		if fullscreen == value:
			return
		fullscreen = value
		_apply_fullscreen()
		_save_options()

var music_volume: float = DEFAULT_MUSIC_VOLUME:
	get():
		return music_volume
	set(value):
		if music_volume == value:
			return
		music_volume = value
		_apply_bus_volume(&"Music", music_volume)
		_save_options()

var master_volume: float = DEFAULT_MASTER_VOLUME:
	get():
		return master_volume
	set(value):
		if master_volume == value:
			return
		master_volume = value
		_apply_bus_volume(&"Master", master_volume)
		_save_options()

var sfx_volume: float = DEFAULT_SFX_VOLUME:
	get():
		return sfx_volume
	set(value):
		if sfx_volume == value:
			return
		sfx_volume = value
		_apply_bus_volume(&"Sfx", sfx_volume)
		_save_options()

var eula_accepted_version: String = DEFAULT_EULA_VERSION:
	get():
		return eula_accepted_version
	set(value):
		if eula_accepted_version == value:
			return
		eula_accepted_version = value
		_save_options()

var _base_master_db: float
var _base_music_db: float
var _base_sfx_db: float


func _ready() -> void:
	print(&"Options: Initializing...")
	process_mode = Node.PROCESS_MODE_ALWAYS

	# get base Db from the default buss setup
	_base_master_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Master"))
	_base_music_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Music"))
	_base_sfx_db = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(&"Sfx"))

	_load_options()
	_apply_all_settings()


func _load_options() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: int = config.load(CONFIG_PATH)

	if err == OK:
		fullscreen = config.get_value(SECTION_DISPLAY, &"fullscreen", DEFAULT_FULLSCREEN)
		master_volume = config.get_value(SECTION_AUDIO, &"master_volume", DEFAULT_MASTER_VOLUME)
		music_volume = config.get_value(SECTION_AUDIO, &"music_volume", DEFAULT_MUSIC_VOLUME)
		sfx_volume = config.get_value(SECTION_AUDIO, &"sfx_volume", DEFAULT_SFX_VOLUME)
		eula_accepted_version = config.get_value(
			SECTION_EULA, &"accepted_version", DEFAULT_EULA_VERSION
		)
	else:
		# First time launch or missing config - set defaults
		fullscreen = DEFAULT_FULLSCREEN
		master_volume = DEFAULT_MASTER_VOLUME
		music_volume = DEFAULT_MUSIC_VOLUME
		sfx_volume = DEFAULT_SFX_VOLUME
		eula_accepted_version = DEFAULT_EULA_VERSION


func _save_options() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value(SECTION_DISPLAY, &"fullscreen", fullscreen)
	config.set_value(SECTION_AUDIO, &"master_volume", master_volume)
	config.set_value(SECTION_AUDIO, &"music_volume", music_volume)
	config.set_value(SECTION_AUDIO, &"sfx_volume", sfx_volume)
	config.set_value(SECTION_EULA, &"accepted_version", eula_accepted_version)

	var err: int = config.save(CONFIG_PATH)
	if err != OK:
		printerr(&"Options: Failed to save config to %s. Error: %d !" % [CONFIG_PATH, err])


func is_eula_accepted(minor_version: String) -> bool:
	return eula_accepted_version == minor_version


func _apply_all_settings() -> void:
	_apply_fullscreen()
	_apply_bus_volume(&"Master", master_volume)
	_apply_bus_volume(&"Music", music_volume)
	_apply_bus_volume(&"Sfx", sfx_volume)


func _apply_fullscreen() -> void:
	DisplayServer.window_set_mode(
		(
			DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN
			if fullscreen
			else DisplayServer.WindowMode.WINDOW_MODE_WINDOWED
		)
	)


func _apply_bus_volume(bus_name: StringName, volume_linear: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		var base_db: float
		match bus_name:
			&"Music":
				base_db = _base_music_db
			&"Sfx":
				base_db = _base_sfx_db
			_:
				base_db = _base_master_db

		# Convert linear 0.0-1.0 to Db offset, and apply to the base Db
		var volume_db: float = (
			base_db + linear_to_db(volume_linear) if volume_linear > 0.0 else -80.0
		)
		AudioServer.set_bus_volume_db(bus_index, volume_db)
	else:
		printerr(&"Options: Audio Bus '%s' not found!" % bus_name)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		get_tree().quit()
	else:
		if event.is_action_pressed(&"toggle_fullscreen"):
			fullscreen = not fullscreen
