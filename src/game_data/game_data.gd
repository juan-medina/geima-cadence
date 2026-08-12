# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

extends Node

const CONFIG_PATH: String = &"user://gamedata.cfg"
const SECTION_SESSION: StringName = &"session"
const SECTION_RECORDS: StringName = &"records"
const SECTION_ENDINGS: StringName = &"endings"

var difficulty: Track.DifficultType = Track.DifficultType.NORMAL
var last_song_id: StringName = &""

# star_records format: { song_id_string: { difficulty_int: stars_int } }
var _star_records: Dictionary = {}

# The "escape"/"secret" keys below must match the story.tres sequence ids.
var _escape_unlocked: bool = false
var _secret_unlocked: bool = false


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
		_escape_unlocked = config.get_value(SECTION_ENDINGS, &"escape_unlocked", false)
		_secret_unlocked = config.get_value(SECTION_ENDINGS, &"secret_unlocked", false)
	else:
		difficulty = Track.DifficultType.NORMAL
		last_song_id = &""
		_star_records = {}
		_escape_unlocked = false
		_secret_unlocked = false


func save_data() -> void:
	var config: ConfigFile = ConfigFile.new()

	config.set_value(SECTION_SESSION, &"difficulty", difficulty)
	config.set_value(SECTION_SESSION, &"last_song_id", last_song_id)
	config.set_value(SECTION_RECORDS, &"stars", _star_records)
	config.set_value(SECTION_ENDINGS, &"escape_unlocked", _escape_unlocked)
	config.set_value(SECTION_ENDINGS, &"secret_unlocked", _secret_unlocked)

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


func ending_unlocked(story_id: StringName) -> bool:
	if story_id == &"secret":
		return _secret_unlocked
	return _escape_unlocked


func latch_ending_unlocked(story_id: StringName) -> void:
	if story_id == &"secret":
		if _secret_unlocked:
			return
		_secret_unlocked = true
	else:
		if _escape_unlocked:
			return
		_escape_unlocked = true
	save_data()
