# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

extends CanvasLayer

enum MenuTarget { MAIN_MENU, SONG_SELECTION }

const FADE_DURATION: float = 1.5
const FADE_PHASE: float = FADE_DURATION / 3
const SILENT_DB: float = -80.0

const GAME_SCENE: PackedScene = preload("res://game/game.tscn")
const MENU_SCENE: PackedScene = preload("res://menu/menu.tscn")
const STORY_SCENE: PackedScene = preload("res://storyboard/storyboard.tscn")
const ERROR_DIALOG: PackedScene = preload("res://error_dialog/error_dialog.tscn")

var in_transition: bool = false
var filler: ColorRect = null

# Read by the storyboard on load to pick which sequence to play.
var pending_story_id: StringName = &"intro"

# Read by the menu on load to pick which panel to open.
var pending_menu_target: MenuTarget = MenuTarget.MAIN_MENU

var _terminating: bool = false


func _ready() -> void:
	layer = 9999
	# keep processing while the tree is paused during a transition
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	filler = ColorRect.new()
	filler.color = Color(0, 0, 0, 0)
	filler.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(filler)

	# Intercept the window-close request so termination fades gracefully.
	get_tree().set_auto_accept_quit(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit_game()


func go_to_game(difficulty: Track.DifficultType, song_id: StringName) -> void:
	GameData.difficulty = difficulty
	GameData.last_song_id = song_id
	GameData.save_data()
	await reload_game()


func reload_game() -> void:
	await _go_to_scene(GAME_SCENE)


func go_to_menu(target: MenuTarget) -> void:
	pending_menu_target = target
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

	# Drop focus so a second accept during the fade hits no button.
	get_viewport().gui_release_focus()

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

	# A fatal error in the new scene's _ready leaves us black; let _terminate finish.
	if _terminating:
		return

	#fade in
	await filler.create_tween().tween_property(filler, ^"color:a", 0.0, FADE_PHASE).finished

	visible = false
	in_transition = false


func quit_game() -> void:
	_terminate(false, &"")


func fatal_error(user_message: StringName) -> void:
	# The caller logs the technical detail; this shows the short line and quits.
	_terminate(true, user_message)


func _terminate(is_error: bool, message: StringName) -> void:
	if _terminating:
		return
	_terminating = true

	var tree: SceneTree = get_tree()
	tree.paused = true
	visible = true

	var master_index: int = AudioServer.get_bus_index(&"Master")
	var start_db: float = AudioServer.get_bus_volume_db(master_index)
	var set_db: Callable = Callable(Audio, &"set_master_volume_db")

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(filler, ^"color:a", 1.0, FADE_PHASE)
	tween.tween_method(set_db, start_db, SILENT_DB, FADE_PHASE)
	await tween.finished

	Audio.stop_all_players(tree.root)

	if is_error:
		_show_error_dialog(message)
		return

	if OS.has_feature(&"web"):
		JavaScriptBridge.eval("window.location.href = 'about:blank';")
		return
	tree.quit()


func _show_error_dialog(message: StringName) -> void:
	var dialog: ErrorDialog = ERROR_DIALOG.instantiate()
	add_child(dialog)
	dialog.setup(message)
