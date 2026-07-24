# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Game
extends Node2D

# Obstacles rest this far below the hero's ground line
const _OBSTACLE_OFFSET_Y: float = 22.0

# Survives scene reloads. A retry replays the same difficulty and skips the
# selection screen (the first gesture has already unlocked audio); "change
# difficulty" flips this back on so the reload asks again.
static var _show_selection: bool = true

# The difficulty the player last chose, replayed on retry across reloads.
static var _selected_difficulty: Track.DifficultType = Track.DifficultType.NORMAL

@onready var _track: Track = $Track
@onready var _biome: Biome = $Biome
@onready var _start_overlay: CanvasLayer = $StartOverlay
@onready var _easy_button: Button = $StartOverlay/Center/VBox/Buttons/Easy
@onready var _normal_button: Button = $StartOverlay/Center/VBox/Buttons/Normal
@onready var _hard_button: Button = $StartOverlay/Center/VBox/Buttons/Hard
@onready var _retry_overlay: CanvasLayer = $RetryOverlay
@onready var _retry_button: Button = $RetryOverlay/Center/VBox/Retry
@onready var _camera: Camera2D = $Camera2D
@onready var _hero: Hero = $Hero
@onready var _hud: Hud = $Hud


func _ready() -> void:
	_hero.died.connect(_on_hero_died)
	_hero.dashed.connect(_biome.dash_burst)

	# Workaround for Godot 4 Camera2D not re-centering after the window resizes.
	get_tree().root.size_changed.connect(_on_window_resized)

	# Temporary: a random biome each load so every one gets seen while testing.
	# This will come from stage selection later.
	_set_biome(randi_range(1, 4))

	if _show_selection:
		match _selected_difficulty:
			Track.DifficultType.EASY:
				_easy_button.grab_focus()
			Track.DifficultType.NORMAL:
				_normal_button.grab_focus()
			Track.DifficultType.HARD:
				_hard_button.grab_focus()
			_:
				push_error("invalid difficulty")
	else:
		_start_run(_selected_difficulty)


# Applies a biome: the Biome node loads its art and colours, then hands back the
# ground line the hero and obstacles share. Background and Fog read the Biome
# directly, so they need no telling — they redraw every frame. The track spawns
# its obstacles in begin(), after this has set floor_y.
func _set_biome(biome: int) -> void:
	_biome.set_biome(biome)
	var ground_y: float = _biome.ground_y()
	_hero.set_ground_y(ground_y)
	_track.floor_y = ground_y + _OBSTACLE_OFFSET_Y


func _on_window_resized() -> void:
	_camera.enabled = false
	_camera.enabled = true
	_camera.force_update_scroll()


# Each difficulty button routes here through its own handler (wired in the
# editor's Signals panel).
func _on_easy_pressed() -> void:
	_start_run(Track.DifficultType.EASY)


func _on_normal_pressed() -> void:
	_start_run(Track.DifficultType.NORMAL)


func _on_hard_pressed() -> void:
	_start_run(Track.DifficultType.HARD)


func _start_run(chosen: Track.DifficultType) -> void:
	_selected_difficulty = chosen
	_start_overlay.visible = false
	# The game picks the difficulty and asks it, to begin the run.
	_track.begin(chosen)


func _on_hero_died() -> void:
	# The player has finished dying, but the health bar may still be draining, so
	# the retry waits for whichever of the two finishes last.
	await _hud.health_settled()

	# Pausing holds the scenery and the song still; the overlay runs on anyway
	# because its process mode is set to run while paused. It has to come after
	# the await: a paused tween would never finish.
	_retry_overlay.visible = true
	_retry_button.grab_focus()
	get_tree().paused = true


func _on_retry_pressed() -> void:
	# Same difficulty, no selection screen.
	_show_selection = false
	# The reloaded scene inherits the paused flag, so it has to be cleared here.
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_change_difficulty_pressed() -> void:
	# Reload and ask for the difficulty again.
	_show_selection = true
	get_tree().paused = false
	get_tree().reload_current_scene()
