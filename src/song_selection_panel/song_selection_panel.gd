# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name SongSelectionPanel
extends MenuPanel

signal back_requested

const SONG_ROW: PackedScene = preload("res://song_row/song_row.tscn")

@export var catalogue: Catalogue = null

@onready var _play_button: Button = %Play
@onready var _easy_button: DifficultyButton = %Easy
@onready var _songs_list: VBoxContainer = %SongList


func _ready() -> void:
	super._ready()
	if not catalogue or not catalogue.biomes or catalogue.biomes.is_empty():
		printerr(&"BiomeCarouselPanel needs a non-empty Catalogue!")
		get_tree().quit()
		return
	if not SONG_ROW:
		printerr(&"SONG_ROW PackedScene is null!")
		get_tree().quit()
		return
	var first: bool = true
	for biome: BiomeEntry in catalogue.biomes:
		var biome_label: Label = Label.new()
		biome_label.text = biome.name
		_songs_list.add_child(biome_label)
		for song: SongEntry in biome.songs:
			if not song:
				printerr(&"Invalid song entry in biome: %s" % biome.name)
				continue
			var new_song_row: SongRow = SONG_ROW.instantiate() as SongRow
			new_song_row.text = song.name
			if first:
				new_song_row.button_pressed = true
				_on_song_row_pressed(new_song_row)
				first = false
			new_song_row.pressed.connect(_on_song_row_pressed.bind(new_song_row))
			_songs_list.add_child(new_song_row)
			Audio._connect_button(new_song_row)


func first_focus_control() -> Control:
	return _play_button


func _on_back_pressed() -> void:
	back_requested.emit()


func _selected_difficulty() -> Track.DifficultType:
	return (_easy_button.button_group.get_pressed_button() as DifficultyButton).difficulty


func _on_play_pressed() -> void:
	await Transition.go_to_game(_selected_difficulty(), 1)


func _on_song_row_pressed(_song_row: SongRow) -> void:
	pass
