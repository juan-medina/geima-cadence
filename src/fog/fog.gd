# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Fog
extends Node2D

# Draws the biome's frontmost layer on top of the hero and obstacles (via a
# higher z_index set in the scene). Like Background it only renders; the Biome
# node owns the texture and the scroll maths.
@export var biome: Biome


func _ready() -> void:
	if not biome:
		push_error("Fog needs a Biome reference!")


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if not biome or not biome.has_fog():
		return

	var view: Vector2 = get_viewport_rect().size
	biome.draw_layer(self, biome.fog_layer(), biome.fog_offset(), view.x)
