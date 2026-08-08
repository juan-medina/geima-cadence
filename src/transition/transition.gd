# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

extends CanvasLayer

const FADE_DURATION: float = 1.5
const FADE_PHASE: float = FADE_DURATION / 3

const GAME_SCENE: PackedScene = preload("res://game/game.tscn")
const MENU_SCENE: PackedScene = preload("res://menu/menu.tscn")
const STORY_SCENE: PackedScene = preload("res://storyboard/storyboard.tscn")

var in_transition: bool = false
var filler: ColorRect = null

# Read by the storyboard on load to pick which sequence to play.
var pending_story_id: StringName = &"intro"


func _ready() -> void:
	layer = 9999
	# keep processing while the tree is paused during a transition
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	filler = ColorRect.new()
	filler.color = Color(0, 0, 0, 0)
	filler.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(filler)


func go_to_game(difficulty: Track.DifficultType, song_id: StringName) -> void:
	GameData.difficulty = difficulty
	GameData.last_song_id = song_id
	GameData.save_data()
	await reload_game()


func reload_game() -> void:
	await _go_to_scene(GAME_SCENE)


func go_to_menu() -> void:
	await _go_to_scene(MENU_SCENE)


func go_to_menu_instant() -> void:
	get_tree().change_scene_to_packed.call_deferred(MENU_SCENE)


func go_to_story(id: StringName) -> void:
	pending_story_id = id
	await _go_to_scene(STORY_SCENE)


func go_to_story_instant(id: StringName) -> void:
	pending_story_id = id
	get_tree().change_scene_to_packed.call_deferred(STORY_SCENE)


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
