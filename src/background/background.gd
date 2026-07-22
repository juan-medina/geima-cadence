# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Background
extends Node2D

# Draws the biome's back layers (everything behind the hero) and the solid fill
# above and below the art. It only renders: the Biome node owns the textures,
# colours and scroll maths.
@export var biome: Biome


func _ready() -> void:
	if not biome:
		push_error("Background needs a Biome reference!")


func _process(_delta: float) -> void:
	queue_redraw()


# Pull from the biome each frame: _draw runs after every node has processed, so
# the track scroll its offsets derive from is the current frame's.
func _draw() -> void:
	if not biome or biome.back_layer_count() == 0:
		return

	# In viewport stretch the canvas grows on wider-than-16:9 screens, and the
	# camera is centred on the origin, so the visible region is symmetric.
	var view: Vector2 = get_viewport_rect().size

	# Fill above and below the horizon with the two edge colours. The opaque art
	# covers the seam at the split, so it only shows where the viewport is taller
	# than the art.
	var split: float = biome.fill_split()
	draw_rect(Rect2(-view.x / 2.0, -view.y / 2.0, view.x, split + view.y / 2.0), biome.top_color())
	draw_rect(Rect2(-view.x / 2.0, split, view.x, view.y / 2.0 - split), biome.bottom_color())

	for index: int in biome.back_layer_count():
		biome.draw_layer(self, biome.back_layer(index), biome.back_layer_offset(index), view.x)
