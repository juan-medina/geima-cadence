# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name SongSelectionPanel
extends MenuPanel

const SONG_ROW: PackedScene = preload("res://song_row/song_row.tscn")

@export var catalogue: Catalogue = null

var _selected_song_row: SongRow = null
var _preview_textures: Array[TextureRect] = []

@onready var _play_button: Button = %Play
@onready var _easy_button: DifficultyButton = %Easy
@onready var _songs_list: VBoxContainer = %SongList
@onready var _song_name_label: Label = %SongName
@onready var _biome_name_label: Label = %BiomeName
@onready var _bpm_label: Label = %BPM
@onready var _details_panel: VBoxContainer = %Details
@onready var _total_stars_label: Label = %TotalStars
@onready var _header_star: Star = $VBoxContainer/Header/Stars/Star


func _ready() -> void:
	super._ready()
	if not _is_setup_valid():
		return
	_build_catalogue_ui()


func _is_setup_valid() -> bool:
	if not catalogue or not catalogue.biomes or catalogue.biomes.is_empty():
		printerr(&"BiomeCarouselPanel needs a non-empty Catalogue!")
		get_tree().quit()
		return false
	if not SONG_ROW:
		printerr(&"SONG_ROW PackedScene is null!")
		get_tree().quit()
		return false
	return true


func _build_catalogue_ui() -> void:
	var states: Array[Completion.State] = []
	for biome: BiomeEntry in catalogue.biomes:
		if biome.songs.is_empty():
			continue
		_add_biome_header(biome)
		if not _add_biome_preview(biome):
			return
		states.append_array(_add_biome_songs(biome))

	_update_header(states)

	if _easy_button and _easy_button.button_group:
		for btn: BaseButton in _easy_button.button_group.get_buttons():
			var diff_btn: DifficultyButton = btn as DifficultyButton
			if diff_btn:
				diff_btn.set_pressed_no_signal(diff_btn.difficulty == GameData.difficulty)


func _add_biome_header(biome: BiomeEntry) -> void:
	var biome_label: Label = Label.new()
	biome_label.text = biome.name
	_songs_list.add_child(biome_label)


func _add_biome_preview(biome: BiomeEntry) -> bool:
	var texture_rect: TextureRect = _create_preview(biome)
	if texture_rect == null:
		return false
	_details_panel.add_child(texture_rect)
	_details_panel.move_child(texture_rect, 0)
	_preview_textures.append(texture_rect)
	return true


func _add_biome_songs(biome: BiomeEntry) -> Array[Completion.State]:
	var states: Array[Completion.State] = []
	for song: SongEntry in biome.songs:
		if not song:
			printerr(&"Invalid song entry in biome: %s" % biome.name)
			continue
		var new_song_row: SongRow = SONG_ROW.instantiate() as SongRow
		new_song_row.text = song.name
		new_song_row.biome = biome
		new_song_row.song = song

		var ranks: Array[Rank.Level] = []
		for diff: int in Track.DifficultType.values():
			ranks.append(GameData.get_star_record(song.id, diff as Track.DifficultType))
		new_song_row.ranks = ranks
		states.append(Completion.from_ranks(ranks))

		new_song_row.pressed.connect(_on_song_row_pressed.bind(new_song_row))
		new_song_row.focus_entered.connect(_on_song_row_focused.bind(new_song_row))

		_songs_list.add_child(new_song_row)
		Audio._connect_button(new_song_row)

		var is_match: bool = String(song.id) == String(GameData.last_song_id)
		if is_match or not _selected_song_row:
			new_song_row.button_pressed = true
			_on_song_row_pressed(new_song_row)
	return states


func _update_header(states: Array[Completion.State]) -> void:
	var world: Completion.State = Completion.from_states(states)
	_total_stars_label.text = _header_text(world, states)
	_total_stars_label.add_theme_color_override(&"font_color", Completion.color(world))
	_header_star.visible = world == Completion.State.MASTERING or world == Completion.State.MASTERED


func _header_text(world: Completion.State, states: Array[Completion.State]) -> String:
	if not (world == Completion.State.ESCAPING or world == Completion.State.MASTERING):
		return Completion.string(world)

	var count: int = 0
	if world == Completion.State.ESCAPING:
		count = _escaped_count(states)
	elif world == Completion.State.MASTERING:
		count = _mastered_count(states)
	return &"%s %d / %d" % [Completion.string(world), count, states.size()]


func _escaped_count(states: Array[Completion.State]) -> int:
	var count: int = 0
	for state: Completion.State in states:
		if state != Completion.State.ESCAPING:
			count += 1
	return count


func _mastered_count(states: Array[Completion.State]) -> int:
	var count: int = 0
	for state: Completion.State in states:
		if state == Completion.State.MASTERED:
			count += 1
	return count


func first_focus_control() -> Control:
	return _play_button


func _on_back_pressed() -> void:
	back_requested.emit()


func _selected_difficulty() -> Track.DifficultType:
	return (_easy_button.button_group.get_pressed_button() as DifficultyButton).difficulty


func _selected_song_id() -> StringName:
	return _selected_song_row.song.id


func _on_play_pressed() -> void:
	await Transition.go_to_game(_selected_difficulty(), _selected_song_id())


func _on_song_row_focused(song_row: SongRow) -> void:
	# update the details panel with the selected song's information
	_song_name_label.text = song_row.song.name
	_biome_name_label.text = song_row.biome.name
	_bpm_label.text = &"%d BPM" % song_row.song.bpm
	_selected_song_row = song_row

	# show the correct biome preview texture for the selected song
	for i: int in range(_preview_textures.size()):
		_preview_textures[i].visible = (i == song_row.biome.id - 1)

	# update the difficulty buttons with the correct star rank for the selected song
	for btn: BaseButton in _easy_button.button_group.get_buttons():
		var diff_btn: DifficultyButton = btn as DifficultyButton
		if diff_btn:
			diff_btn.rank = GameData.get_star_record(song_row.song.id, diff_btn.difficulty)


func _on_song_row_pressed(song_row: SongRow) -> void:
	_on_song_row_focused(song_row)
	_play_button.grab_focus()


func _create_preview(biome: BiomeEntry) -> TextureRect:
	var texture_rect: TextureRect = TextureRect.new()
	var path: String = "res://data/assets/backgrounds/bg_%d_preview.png" % biome.id
	var texture: Texture2D = load(path) as Texture2D
	if texture == null:
		printerr("fail to load texture %s" % path)
		get_tree().quit()
		return null
	texture_rect.texture = texture
	texture_rect.custom_minimum_size = Vector2(50, 110)
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.visible = false
	return texture_rect


func _on_difficulty_button_pressed() -> void:
	_play_button.grab_focus()
