# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Obstacle
extends Area2D

signal hit_player

enum Type { NONE, SLASH, DASH, SLIDE, JUMP_UP }

const _GLYPH_SCALE: Vector2 = Vector2(1.5, 1.5)
const _GLYPH_Z_INDEX: int = 3

# Matches the energy core mote colour so a defeated glyph reads as fed into it.
const _GLYPH_SUCCESS_COLOR: Color = Color(0.7, 0.92, 1.0)
const _GLYPH_FAIL_COLOR: Color = Color(1.0, 0.0, 0.0)
const _GLYPH_FLASH_DURATION: float = 0.08
const _GLYPH_FADE_DURATION: float = 0.3

static var _glyph_additive_material: CanvasItemMaterial

# Set by each obstacle's own script.
var type: Type = Type.NONE

var _resolved: bool = false

@onready var _glyph: Sprite2D = $Sprite2D


func place_glyph_on_lane(lane_y: float, floor_y: float) -> void:
	_glyph.position.y = lane_y - floor_y
	_glyph.scale = _GLYPH_SCALE
	_glyph.z_as_relative = false
	_glyph.z_index = _GLYPH_Z_INDEX


# How long before contact this threat counts the player as near. A threat that
# acts on the beat asks for the time its own action takes to land.
func near_time() -> float:
	return 0.0


# The player is near_time() away. Runs before he has committed, so nothing here
# may depend on what he ends up doing.
func on_player_near() -> void:
	pass


func resolve(action: Type) -> bool:
	if _resolved:
		return false
	_resolved = true
	if action == type:
		_fade_glyph_success()
		_on_player_success()
		return false
	_fade_glyph_failure()
	_on_player_failure()
	return true


# Called by the hero after a miss, but only while it is still alive — a fatal hit
# never turns the threat. Threats that react to being passed override this.
func on_player_passed() -> void:
	pass


func _fade_glyph_success() -> void:
	if not _glyph_additive_material:
		_glyph_additive_material = CanvasItemMaterial.new()
		_glyph_additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_glyph.material = _glyph_additive_material
	var faded: Color = _GLYPH_SUCCESS_COLOR
	faded.a = 0.0
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(_glyph, ^"modulate", faded, _GLYPH_FADE_DURATION)


func _fade_glyph_failure() -> void:
	var faded: Color = _GLYPH_FAIL_COLOR
	faded.a = 0.0
	var fail_tween: Tween = create_tween()
	fail_tween.tween_property(_glyph, ^"modulate", _GLYPH_FAIL_COLOR, _GLYPH_FLASH_DURATION)
	fail_tween.tween_property(_glyph, ^"modulate", faded, _GLYPH_FADE_DURATION)


func _on_player_success() -> void:
	pass


func _on_player_failure() -> void:
	hit_player.emit()
