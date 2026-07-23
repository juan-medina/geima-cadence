# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Biome
extends Node

# Owns everything that differs between biomes: which parallax layers to load, the
# solid colours that fill the screen above and below the art, the hero's ground
# line, and the scroll maths the render nodes ask for. Background and Fog only
# draw; they hold a reference to this node and pull what they need. The per-biome
# numbers live in code for now and will move to JSON with stage selection.

const _LAYER_PATH: String = "res://data/assets/backgrounds/bg_%d_layer_%d.png"

# Extra scroll distance the dash burst adds to the parallax layers, and how long
# the surge takes to decay back to the normal scroll speed.
const _DASH_BURST_DISTANCE: float = 100.0
const _DASH_BURST_DURATION: float = 0.4

# Read each frame to turn the track scroll into every layer's parallax offset.
@export var track: Node2D

# Parallax speed of the backmost layer as a fraction of the track scroll: the
# slowest, most distant layer. Layers ramp from this up to 1.0 at the ground
# layer, which shares the obstacles' plane and so must scroll at the exact object
# speed or the obstacles visibly slide along it.
@export var far_factor: float = 0.1

# The fog drifts on top at its own parallax speed, slower than the ground so it
# reads as its own layer instead of being pinned to the objects.
@export var fog_factor: float = 0.6

# Nudges every layer vertically to line the art's ground up with the gameplay
# floor.
@export var ground_offset: float = 0.0

var _biome: int = 1
var _layers: Array[Texture2D] = []
# Filled behind the art above and below the horizon. The two edges are different
# colours (sky at the top, fog-tinted ground at the bottom), so they are read
# from the composited stack, not from a single layer.
var _top_color: Color = Color.BLACK
var _bottom_color: Color = Color.BLACK

# Accumulated extra scroll from dash bursts. It only ever grows (fmod wraps it),
# so a burst never rewinds: it reads as a speed surge that eases back to normal.
var _burst: float = 0.0
var _burst_tween: Tween


func _ready() -> void:
	if not track:
		push_error("Biome needs a Track reference!")


# The game picks the biome; loading its layers and sampling its colours happens
# here so the render nodes stay dumb.
func set_biome(new_biome: int) -> void:
	_biome = new_biome
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


# The ground line the hero and the obstacles share, which differs because each
# biome's ground sits at a different height. A switch for now; moves to JSON with
# stage selection.
func ground_y() -> float:
	match _biome:
		2:
			return 115.0
		_:
			return 130.0


# The back layers are everything except the frontmost, which is the fog the Fog
# node draws on top of the hero.
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


# Split between the two fill colours; the opaque art covers it, so it only shows
# where the viewport is taller than the art.
func fill_split() -> float:
	return ground_offset


# Tiles one layer across the whole (possibly ultrawide) viewport, drawing onto
# the caller's canvas. Kept here so the copy-placement maths lives in one place
# and the render nodes only decide which layers to draw and in what order.
func draw_layer(canvas: CanvasItem, texture: Texture2D, offset: float, view_width: float) -> void:
	# Layers are authored at the design resolution, so they draw at native size:
	# no scaling, just tiling copies across the viewport.
	var width: float = texture.get_width()
	var height: float = texture.get_height()
	var top: float = -height / 2.0 + ground_offset
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
	# The ground layer shares the obstacle plane and must stay locked to it, so
	# the dash burst only moves the layers behind (and the fog above).
	if factor < 1.0:
		scrolled -= _burst
	return fmod(scrolled * factor, width)


func _factor(index: int) -> float:
	# The fog drifts on top at its own slower speed. The frontmost back layer is
	# the ground the obstacles stand on, so it moves at the object speed (1.0);
	# everything behind ramps from far_factor up to that.
	if index == _layers.size() - 1:
		return fog_factor
	var ground_index: int = _layers.size() - 2
	if index >= ground_index:
		return 1.0
	return lerpf(far_factor, 1.0, float(index) / float(ground_index))


func _load_layers() -> void:
	# Layer count varies per biome, so load bg_<biome>_layer_1, _2, ... until one
	# is missing. ResourceLoader.exists works inside an exported PCK; DirAccess
	# over res:// does not, so it must drive the loop.
	var layer_number: int = 1
	while true:
		var path: String = _LAYER_PATH % [_biome, layer_number]
		if not ResourceLoader.exists(path):
			break
		var texture: Texture2D = load(path) as Texture2D
		if not texture:
			break
		_layers.append(texture)
		layer_number += 1

	if _layers.is_empty():
		push_error("Biome found no layers for biome %d!" % _biome)
		return

	_sample_edge_colors()


func _sample_edge_colors() -> void:
	# The flat top and bottom colours only emerge once every layer is stacked:
	# later layers (e.g. fog) are transparent and tint the ground beneath them.
	# So composite the whole stack once, then read its top and bottom rows. Done
	# at load time because the source art never changes while running.
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
	# blend_rect needs a straight RGBA8 buffer to alpha-composite into.
	image.convert(Image.FORMAT_RGBA8)
	return image
