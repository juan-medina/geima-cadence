# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Background
extends Node2D

const _TILE_WIDTH: float = 128.0
const _TILE_HEIGHT: float = 8.0
const _SCROLL_POS_Y: float = 24.0

const _BG_SCROLL_SPEED: float = 80.0
const _BG_TILE_WIDTH: float = 300.0
const _CEILING_POS_Y: float = -120.0
const _PILLARS_WIDTH: float = 80.0

@export var scroll_speed: float = 250.0
@export var track: Node2D


func _ready() -> void:
	if not track:
		push_error("Background needs a Track reference!")


func _process(_delta: float) -> void:
	queue_redraw()


# Read from the track rather than keeping a copy: _draw runs after every node
# has processed, so this is always the current frame's position.
func _draw() -> void:
	if not track:
		return

	var scroll_offset: float = fmod(track.position.x, _TILE_WIDTH)
	var parallax_ratio: float = _BG_SCROLL_SPEED / scroll_speed
	var bg_scroll_offset: float = fmod(track.position.x * parallax_ratio, _BG_TILE_WIDTH)

	# 1. Draw Parallax Background (Dark Pillars)
	for i: int in range(-10, 10):
		var x_pos: float = (i * _BG_TILE_WIDTH) + bg_scroll_offset
		# Draw a background pillar that extends from ceiling to floor
		var height: float = _SCROLL_POS_Y - _CEILING_POS_Y
		draw_rect(Rect2(x_pos, _CEILING_POS_Y, _PILLARS_WIDTH, height), Color(0.15, 0.15, 0.18))

	# 2. Draw Foreground Floor and Ceiling Tiles
	for i: int in range(-15, 15):
		var x_pos: float = (i * _TILE_WIDTH) + scroll_offset
		# Floor tiles
		draw_rect(Rect2(x_pos, _SCROLL_POS_Y, _TILE_WIDTH / 2.0, _TILE_HEIGHT), Color.DIM_GRAY)
		# Ceiling tiles (upside down)
		draw_rect(
			Rect2(x_pos, _CEILING_POS_Y - _TILE_HEIGHT, _TILE_WIDTH / 2.0, _TILE_HEIGHT),
			Color.DIM_GRAY
		)

	# 3. Draw solid boundary lines
	draw_line(Vector2(-2000, _SCROLL_POS_Y), Vector2(2000, _SCROLL_POS_Y), Color.DARK_GRAY, 4.0)
	draw_line(Vector2(-2000, _CEILING_POS_Y), Vector2(2000, _CEILING_POS_Y), Color.DARK_GRAY, 4.0)
