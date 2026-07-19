# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Background
extends Node2D

@export var scroll_speed: float = 250.0

var _scroll_offset: float = 0.0
var _bg_scroll_offset: float = 0.0

const _TILE_WIDTH: float = 128.0
const _TILE_HEIGHT: float = 8.0
const _SCROLL_POS_Y: float = 24.0

const _BG_SCROLL_SPEED: float = 80.0
const _BG_TILE_WIDTH: float = 300.0
const _CEILING_POS_Y: float = -120.0
const _PILLARS_WIDTH: float = 80.0


func _process(delta: float) -> void:
	# Move the foreground offset backwards to simulate the character running forwards
	_scroll_offset -= scroll_speed * delta
	if _scroll_offset < -_TILE_WIDTH:
		_scroll_offset += _TILE_WIDTH

	# Move the background offset slower for parallax
	_bg_scroll_offset -= _BG_SCROLL_SPEED * delta
	if _bg_scroll_offset < -_BG_TILE_WIDTH:
		_bg_scroll_offset += _BG_TILE_WIDTH

	# Force the node to redraw every frame
	queue_redraw()


func _draw() -> void:
	# 1. Draw Parallax Background (Dark Pillars)
	for i: int in range(-10, 10):
		var x_pos: float = (i * _BG_TILE_WIDTH) + _bg_scroll_offset
		# Draw a background pillar that extends from ceiling to floor
		var height: float = _SCROLL_POS_Y - _CEILING_POS_Y
		draw_rect(Rect2(x_pos, _CEILING_POS_Y, _PILLARS_WIDTH, height), Color(0.15, 0.15, 0.18))

	# 2. Draw Foreground Floor and Ceiling Tiles
	for i: int in range(-15, 15):
		var x_pos: float = (i * _TILE_WIDTH) + _scroll_offset
		# Floor tiles
		draw_rect(Rect2(x_pos, _SCROLL_POS_Y, _TILE_WIDTH / 2.0, _TILE_HEIGHT), Color.DIM_GRAY)
		# Ceiling tiles (upside down)
		draw_rect(Rect2(x_pos, _CEILING_POS_Y - _TILE_HEIGHT, _TILE_WIDTH / 2.0, _TILE_HEIGHT), Color.DIM_GRAY)

	# 3. Draw solid boundary lines
	draw_line(Vector2(-2000, _SCROLL_POS_Y), Vector2(2000, _SCROLL_POS_Y), Color.DARK_GRAY, 4.0)
	draw_line(Vector2(-2000, _CEILING_POS_Y), Vector2(2000, _CEILING_POS_Y), Color.DARK_GRAY, 4.0)
