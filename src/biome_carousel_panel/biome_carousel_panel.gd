# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name BiomeCarouselPanel
extends MenuPanel

signal back_requested

const ACTIVE_PILL: Color = Color.WHITE
const INACTIVE_PILL: Color = Color(0.4, 0.4, 0.4)
const SLIDE_TIME: float = 0.18

@export var catalogue: Catalogue
@export var pill_texture: Texture2D

var _current_biome: int = 0
var _preview_textures: Array[TextureRect] = []
var _pills_textures: Array[TextureRect] = []
var _slide_tween: Tween

@onready var _carousel: Control = %Carousel
@onready var _name: Label = %Name
@onready var _pills: HBoxContainer = %Pills
@onready var _song_list: VBoxContainer = %SongList


func _ready() -> void:
	super._ready()
	if not catalogue or catalogue.biomes.is_empty():
		printerr(&"BiomeCarouselPanel needs a non-empty Catalogue!")
		get_tree().quit()
		return

	for biome: BiomeEntry in catalogue.biomes:
		var texture_rect: TextureRect = _create_preview(biome)
		if texture_rect == null:
			return
		_preview_textures.append(texture_rect)
		_carousel.add_child(texture_rect)
		_carousel.move_child(texture_rect, 0)

		var pill: TextureRect = _create_pill()

		_pills.add_child(pill)
		_pills_textures.append(pill)

	_carousel.clip_contents = true
	_preview_textures[_current_biome].visible = true
	_refresh_info()
	_refresh_songs()


func _create_preview(biome: BiomeEntry) -> TextureRect:
	var texture_rect: TextureRect = TextureRect.new()
	var path: String = "res://data/assets/backgrounds/bg_%d_preview.png" % biome.id
	var texture: Texture2D = load(path) as Texture2D
	if texture == null:
		printerr("fail to load texture %s" % path)
		get_tree().quit()
		return null
	texture_rect.texture = texture
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture_rect.visible = false
	return texture_rect


func _create_pill() -> TextureRect:
	var pill: TextureRect = TextureRect.new()
	pill.texture = pill_texture
	pill.custom_minimum_size = Vector2(20, 8)
	pill.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pill.size_flags_vertical = Control.SIZE_SHRINK_END
	return pill


func _refresh_info() -> void:
	for i: int in _pills_textures.size():
		_pills_textures[i].modulate = ACTIVE_PILL if (i == _current_biome) else INACTIVE_PILL
	_name.text = catalogue.biomes[_current_biome].name


func _refresh_songs() -> void:
	var songs: Array[SongEntry] = catalogue.biomes[_current_biome].songs
	var rows: Array[Node] = _song_list.get_children()
	for i: int in rows.size():
		var row: SongRow = rows[i] as SongRow
		if row == null:
			continue
		row.visible = i < songs.size()
		if row.visible:
			row.setup(songs[i])


func first_focus_control() -> Control:
	return _song_list.get_child(0) as Control


func _on_back_pressed() -> void:
	back_requested.emit()


func _on_right_button_pressed() -> void:
	_cycle(1)


func _on_left_button_pressed() -> void:
	_cycle(-1)


func _cycle(step: int) -> void:
	var previous: int = _current_biome
	_current_biome = wrapi(_current_biome + step, 0, catalogue.biomes.size())
	_slide(previous, _current_biome, step)
	_refresh_info()
	_refresh_songs()


func _slide(from_index: int, to_index: int, direction: int) -> void:
	# Interrupted mid-slide (fast cycling): drop the old tween and snap strays.
	if _slide_tween != null and _slide_tween.is_running():
		_slide_tween.kill()

	var width: float = _carousel.size.x
	var outgoing: TextureRect = _preview_textures[from_index]
	var incoming: TextureRect = _preview_textures[to_index]

	for i: int in _preview_textures.size():
		if i != from_index and i != to_index:
			_preview_textures[i].visible = false
			_preview_textures[i].position.x = 0.0

	outgoing.visible = true
	outgoing.position.x = 0.0
	incoming.visible = true
	incoming.position.x = direction * width

	_slide_tween = create_tween()
	_slide_tween.set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_slide_tween.tween_property(outgoing, ^"position:x", -direction * width, SLIDE_TIME)
	_slide_tween.tween_property(incoming, ^"position:x", 0.0, SLIDE_TIME)
	_slide_tween.chain().tween_callback(outgoing.hide)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_right"):
		_cycle(1)
		Audio.play_click()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"ui_left"):
		_cycle(-1)
		Audio.play_click()
		get_viewport().set_input_as_handled()


func _on_song_row_1_pressed() -> void:
	await _go_to_game()


func _on_song_row_2_pressed() -> void:
	await _go_to_game()


func _on_song_row_3_pressed() -> void:
	await _go_to_game()


func _go_to_game() -> void:
	await Transition.go_to_game(Track.DifficultType.EASY, _current_biome + 1)