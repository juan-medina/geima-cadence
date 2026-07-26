# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

extends CanvasLayer

const FADE_DURATION: float = 1.5
const FADE_PHASE: float = FADE_DURATION / 3

@export var game_scene: PackedScene = null
@export var menu_scene: PackedScene = null

@onready var filler: ColorRect = $Filler

var in_transition: bool = false


func _ready() -> void:
	if not game_scene:
		printerr(&"Game scene is not set in the Transition node.")
		get_tree().quit()
		return
	if not menu_scene:
		printerr(&"Menu scene is not set in the Transition node.")
		get_tree().quit()
		return


func go_to_game(difficulty: Track.DifficultType, biome: int) -> void:
	CurrentRun.difficulty = difficulty
	CurrentRun.biome = biome

	await _go_to_scene(game_scene)


func go_to_menu() -> void:
	await _go_to_scene(menu_scene)


func _go_to_scene(scene: PackedScene) -> void:
	if in_transition:
		return

	var tree: SceneTree = get_tree()

	# pause so no animations, or more clicks
	tree.paused = true
	visible = true
	in_transition = true

	# fade out
	await filler.create_tween().tween_property(filler, ^"color:a", 1.0, FADE_PHASE).finished

	# change is deferred, so yield a frame for the new scene to exist
	tree.change_scene_to_packed.call_deferred(scene)
	tree.paused = false
	await tree.process_frame

	# let it settle behind black so it does not jump on fade in
	await tree.create_timer(FADE_PHASE, true, false, false).timeout

	#fade in
	await filler.create_tween().tween_property(filler, ^"color:a", 0.0, FADE_PHASE).finished

	visible = false
	in_transition = false
