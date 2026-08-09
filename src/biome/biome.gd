# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Biome
extends Node2D

const _LAYER_PATH: String = &"res://data/assets/backgrounds/bg_%d_layer_%d.png"

# configuration for the burst effect
const _DASH_BURST_DISTANCE: float = 100.0
const _DASH_BURST_DURATION: float = 0.4

# Shared banded alpha mask (white RGB) that fades top to bottom; the biome
# modulates it with top_color so each biome dissolves into its own sky.
const _FADE_MASK_PATH: String = &"res://data/assets/backgrounds/top_fade_mask.png"

# Parallax speed of the backmost layer
@export var far_factor: float = 0.1

# The fog, on top of even the ground, enemies and players, has it own parallax speed
@export var fog_factor: float = 0.6

var _layers: Array[Texture2D] = []
var _fade_mask: Texture2D = null

# Filled behind the art above and below the horizon. The two edges are different
# colors (sky at the top, fog-tinted ground at the bottom), so they are read
# from the composited stack, not from a single layer.
var _top_color: Color = Color.BLACK
var _bottom_color: Color = Color.BLACK

var _burst: float = 0.0
var _burst_tween: Tween
var _current_scroll: float = 0.0
var _biome_entry: BiomeEntry = null

var _back_renderer: Node2D
var _front_renderer: Node2D

func _ready() -> void:
	_back_renderer = Node2D.new()
	_back_renderer.z_index = -10
	_back_renderer.draw.connect(_draw_back)
	add_child(_back_renderer)

	_front_renderer = Node2D.new()
	_front_renderer.z_index = 10
	_front_renderer.draw.connect(_draw_front)
	add_child(_front_renderer)

	_fade_mask = load(_FADE_MASK_PATH) as Texture2D
	if _fade_mask == null:
		printerr(&"Biome could not load top-fade mask at %s" % _FADE_MASK_PATH)

func set_scroll(scroll: float) -> void:
	_current_scroll = scroll
	_back_renderer.queue_redraw()
	_front_renderer.queue_redraw()


func load(biome_entry: BiomeEntry) -> void:
	_biome_entry = biome_entry
	_layers.clear()
	_load_layers()


func dash_burst() -> void:
	if _burst_tween:
		_burst_tween.kill()
	_burst_tween = create_tween()
	(
		_burst_tween
		.tween_property(self, ^"_burst", _burst + _DASH_BURST_DISTANCE, _DASH_BURST_DURATION)
		.set_ease(Tween.EASE_OUT)
		.set_trans(Tween.TRANS_CUBIC)
	)


func ground_y() -> float:
	return _biome_entry.floor_offset

func back_layer_count() -> int:
	return maxi(_layers.size() - 1, 0)


func back_layer(index: int) -> Texture2D:
	return _layers[index]


func back_layer_offset(index: int) -> float:
	return _layer_offset(index)


func has_fog() -> bool:
	return _layers.size() > 1


func fog_layer() -> Texture2D:
	return _layers[_layers.size() - 1]


func fog_offset() -> float:
	return _layer_offset(_layers.size() - 1)


func top_color() -> Color:
	return _top_color


func bottom_color() -> Color:
	return _bottom_color


func _draw_back() -> void:
	var view: Vector2 = get_viewport_rect().size

	# We cover the whole screen with the top and bottom color
	_back_renderer.draw_rect(Rect2(-view.x / 2.0, -view.y / 2.0, view.x, view.y / 2.0), top_color())
	_back_renderer.draw_rect(Rect2(-view.x / 2.0, 0.0, view.x, view.y / 2.0), bottom_color())

	# draw all layers
	for index: int in back_layer_count():
		draw_layer(_back_renderer, back_layer(index), back_layer_offset(index), view.x)

	# Must run after the layer loop so the band covers the top edge of every layer.
	_draw_top_fade(view)


# Tiles the fade mask along the art's top edge (anchored there, not centred like
# the layers) painted with top_color, so tall silhouettes dissolve into the sky.
# It drifts horizontally at fog speed like the bottom fog, so the dither reads as
# moving fog rather than a static pane; vertically it stays pinned to the edge.
func _draw_top_fade(view: Vector2) -> void:
	if _fade_mask == null:
		return
	var mask_width: float = _fade_mask.get_width()
	var mask_height: float = _fade_mask.get_height()
	var art_height: float = _layers[0].get_height()
	var art_top: float = - art_height / 2.0
	var tint: Color = top_color()

	var scrolled: float = _current_scroll
	if fog_factor < 1.0:
		scrolled -= _burst
	var offset: float = fmod(scrolled * fog_factor, mask_width)

	var first: int = floori((-view.x / 2.0 - offset) / mask_width)
	var last: int = ceili((view.x / 2.0 - offset) / mask_width)
	for copy: int in range(first, last + 1):
		var rect: Rect2 = Rect2(offset + copy * mask_width, art_top, mask_width, mask_height)
		_back_renderer.draw_texture_rect(_fade_mask, rect, false, tint)


func _draw_front() -> void:
	if not has_fog():
		return
	var view: Vector2 = get_viewport_rect().size
	draw_layer(_front_renderer, fog_layer(), fog_offset(), view.x)


# Tiles one layer across the whole (possibly ultrawide) viewport, drawing onto
# the caller's canvas. Kept here so the copy-placement maths lives in one place
# and the render nodes only decide which layers to draw and in what order.
func draw_layer(canvas: CanvasItem, texture: Texture2D, offset: float, view_width: float) -> void:
	# Layers are authored at the design resolution, so they draw at native size:
	# no scaling, just tiling copies across the viewport.
	var width: float = texture.get_width()
	var height: float = texture.get_height()
	var top: float = - height / 2.0
	var first: int = floori((-view_width / 2.0 - offset) / width)
	var last: int = ceili((view_width / 2.0 - offset) / width)
	for copy: int in range(first, last + 1):
		canvas.draw_texture_rect(texture, Rect2(offset + copy * width, top, width, height), false)


# How far a layer at this index has scrolled, wrapped to one tile so callers tile
# only a handful of copies. Far layers move slowest, the fog fastest.
func _layer_offset(index: int) -> float:
	var width: float = _layers[index].get_width()
	var factor: float = _factor(index)
	var scrolled: float = _current_scroll

	if factor < 1.0:
		scrolled -= _burst
	return fmod(scrolled * factor, width)


func _factor(index: int) -> float:
	if index == _layers.size() - 1:
		return fog_factor
	var ground_index: int = _layers.size() - 2
	if index >= ground_index:
		return 1.0
	return lerpf(far_factor, 1.0, float(index) / float(ground_index))


func _load_layers() -> void:
	var biome_id: int = _biome_entry.id

	var layer_number: int = 1
	while true:
		var path: String = _LAYER_PATH % [biome_id, layer_number]
		if not ResourceLoader.exists(path):
			break
		var texture: Texture2D = load(path) as Texture2D
		if not texture:
			break
		_layers.append(texture)
		layer_number += 1

	if _layers.is_empty():
		printerr(&"Biome found no layers for biome %d!" % biome_id)
		get_tree().quit()
		return

	_sample_edge_colors()


func _sample_edge_colors() -> void:
	var composite: Image = _layer_image(_layers[0])
	var full: Rect2i = Rect2i(0, 0, composite.get_width(), composite.get_height())
	for index: int in range(1, _layers.size()):
		composite.blend_rect(_layer_image(_layers[index]), full, Vector2i.ZERO)

	var mid_x: int = floori(composite.get_width() / 2.0)
	_top_color = composite.get_pixel(mid_x, 0)
	_bottom_color = composite.get_pixel(mid_x, composite.get_height() - 1)


func _layer_image(texture: Texture2D) -> Image:
	var image: Image = texture.get_image()
	if image.is_compressed():
		image.decompress()
	image.convert(Image.FORMAT_RGBA8)
	return image
