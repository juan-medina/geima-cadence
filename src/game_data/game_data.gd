# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

extends Node

const CONFIG_PATH: String = &"user://gamedata.cfg"
const SECTION_SESSION: StringName = &"session"
const SECTION_RECORDS: StringName = &"records"

var difficulty: Track.DifficultType = Track.DifficultType.NORMAL
var last_song_id: StringName = &""

# star_records format: { song_id_string: { difficulty_int: stars_int } }
var _star_records: Dictionary = {}


func _ready() -> void:
	print(&"GameData: Initializing...")
	_load_data()


func _load_data() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: int = config.load(CONFIG_PATH)

	if err == OK:
		difficulty = config.get_value(SECTION_SESSION, &"difficulty", Track.DifficultType.NORMAL)
		last_song_id = config.get_value(SECTION_SESSION, &"last_song_id", &"")
		_star_records = config.get_value(SECTION_RECORDS, &"stars", {})
	else:
		difficulty = Track.DifficultType.NORMAL
		last_song_id = &""
		_star_records = {}


func save_data() -> void:
	var config: ConfigFile = ConfigFile.new()

	config.set_value(SECTION_SESSION, &"difficulty", difficulty)
	config.set_value(SECTION_SESSION, &"last_song_id", last_song_id)
	config.set_value(SECTION_RECORDS, &"stars", _star_records)

	var err: int = config.save(CONFIG_PATH)
	if err != OK:
		printerr(&"GameData: Failed to save config to %s. Error: %d !" % [CONFIG_PATH, err])


func get_star_record(song_id: StringName, diff: Track.DifficultType) -> Rank.Level:
	var song_key: String = String(song_id)
	if _star_records.has(song_key):
		var diffs: Dictionary = _star_records[song_key]
		if diffs.has(diff):
			var val: Variant = diffs[diff]
			if val is int:
				var rank_int: int = str(diffs[diff]).to_int()
				var rank: Rank.Level = rank_int as Rank.Level
				return rank
	return Rank.Level.NONE


func set_star_record(song_id: StringName, diff: Track.DifficultType, stars: Rank.Level) -> void:
	var song_key: String = String(song_id)
	if not _star_records.has(song_key):
		_star_records[song_key] = {}

	var diffs: Dictionary = _star_records[song_key]

	if not diffs.has(diff) or diffs[diff] < stars:
		diffs[diff] = stars
		save_data()
