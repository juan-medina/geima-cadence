# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Biome
extends Node

const _LAYER_PATH: String = &"res://data/assets/backgrounds/bg_%d_layer_%d.png"

# configuration for the burst effect
const _DASH_BURST_DISTANCE: float = 100.0
const _DASH_BURST_DURATION: float = 0.4

@export var track: Track

# Parallax speed of the backmost layer
@export var far_factor: float = 0.1

# The fog, on top of even the ground, enemies and players, has it own parallax speed
@export var fog_factor: float = 0.6

var _layers: Array[Texture2D] = []

# Filled behind the art above and below the horizon. The two edges are different
# colours (sky at the top, fog-tinted ground at the bottom), so they are read
# from the composited stack, not from a single layer.
var _top_color: Color = Color.BLACK
var _bottom_color: Color = Color.BLACK

var _burst: float = 0.0
var _burst_tween: Tween


func _ready() -> void:
	if not track:
		printerr(&"Biome needs a Track reference!")
		get_tree().quit()


func load() -> void:
	_layers.clear()
	_load_layers()


func dash_burst() -> void:
	if _burst_tween:
		_burst_tween.kill()
	_burst_tween = create_tween()
	(
		_burst_tween
		. tween_property(self, ^"_burst", _burst + _DASH_BURST_DISTANCE, _DASH_BURST_DURATION)
		. set_ease(Tween.EASE_OUT)
		. set_trans(Tween.TRANS_CUBIC)
	)


# The ground change between biomes
func ground_y() -> float:
	match CurrentRun.biome:
		3:
			return 115.0
		_:
			return 130.0


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


# Tiles one layer across the whole (possibly ultrawide) viewport, drawing onto
# the caller's canvas. Kept here so the copy-placement maths lives in one place
# and the render nodes only decide which layers to draw and in what order.
func draw_layer(canvas: CanvasItem, texture: Texture2D, offset: float, view_width: float) -> void:
	# Layers are authored at the design resolution, so they draw at native size:
	# no scaling, just tiling copies across the viewport.
	var width: float = texture.get_width()
	var height: float = texture.get_height()
	var top: float = -height / 2.0
	var first: int = floori((-view_width / 2.0 - offset) / width)
	var last: int = ceili((view_width / 2.0 - offset) / width)
	for copy: int in range(first, last + 1):
		canvas.draw_texture_rect(texture, Rect2(offset + copy * width, top, width, height), false)


# How far a layer at this index has scrolled, wrapped to one tile so callers tile
# only a handful of copies. Far layers move slowest, the fog fastest.
func _layer_offset(index: int) -> float:
	if not track:
		return 0.0
	var width: float = _layers[index].get_width()
	var factor: float = _factor(index)
	var scrolled: float = track.position.x

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
	var layer_number: int = 1
	while true:
		var path: String = _LAYER_PATH % [CurrentRun.biome, layer_number]
		if not ResourceLoader.exists(path):
			break
		var texture: Texture2D = load(path) as Texture2D
		if not texture:
			break
		_layers.append(texture)
		layer_number += 1

	if _layers.is_empty():
		printerr(&"Biome found no layers for biome %d!" % CurrentRun.biome)
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
