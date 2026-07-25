# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Background
extends Node2D

@export var biome: Biome


func _ready() -> void:
	if not biome:
		push_error("Background needs a Biome reference!")


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var view: Vector2 = get_viewport_rect().size

	# We cover the wole screem with the top and bottom color
	draw_rect(Rect2(-view.x / 2.0, -view.y / 2.0, view.x, view.y / 2.0), biome.top_color())
	draw_rect(Rect2(-view.x / 2.0, view.y / 2.0, view.x, view.y / 2.0), biome.bottom_color())

	# draw all layers
	for index: int in biome.back_layer_count():
		biome.draw_layer(self, biome.back_layer(index), biome.back_layer_offset(index), view.x)
