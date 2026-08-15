# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Storyboard
extends CanvasLayer

const _CHAR_TIME: float = 0.05
const _MIN_REVEAL: float = 1.0
# Reading-rhythm pauses after punctuation, not randomness: a comma gets a
# short breath, a sentence-ender gets a longer one, same as a JRPG text box.
const _WEAK_PUNCTUATION: String = ",;:-"
const _STRONG_PUNCTUATION: String = ".!?"
const _PAUSE_WEAK: float = 0.15
const _PAUSE_STRONG: float = 0.35
const _HOLD_PER_CHAR: float = 0.045
const _MIN_HOLD: float = 1.4
const _FINAL_HOLD: float = 15.0
const _CAPTION_FADE: float = 0.35

@export var catalogue: StoryCatalogue

var _skip_step: bool = false
var _skip_all: bool = false

@onready var _biome: Biome = $SubViewportContainer/SubViewport/Biome
@onready var _caption: RichTextLabel = $CaptionBox/Caption
@onready var _music: AudioStreamPlayer = $Music


func _ready() -> void:
	_caption.modulate.a = 0.0
	await _play()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") or event.is_action_pressed(&"back"):
		_skip_all = true
		_skip_step = true
		return
	if event.is_action_pressed(&"ui_accept") or _is_mouse_click(event):
		_skip_step = true


func _is_mouse_click(event: InputEvent) -> bool:
	var mouse_button: InputEventMouseButton = event as InputEventMouseButton
	if mouse_button == null:
		return false
	# button_index <= MIDDLE keeps left/right/middle clicks and drops wheel scroll.
	return mouse_button.pressed and mouse_button.button_index <= MOUSE_BUTTON_MIDDLE


func _play() -> void:
	var sequence_id: StringName = Transition.pending_story_id
	var sequence: StorySequence = null
	if catalogue != null:
		sequence = catalogue.sequence_for(sequence_id)
	if sequence == null:
		printerr(&"Storyboard: no sequence for id %s" % sequence_id)
		Transition.fatal_error(&"Could not load the story")
		return

	_load_biome(sequence)
	_start_music(sequence)

	var slide_count: int = sequence.slides.size()
	var index: int = 1
	for slide: StorySlide in sequence.slides:
		if _skip_all:
			break
		await _show_slide(slide, index == slide_count)
		index += 1

	await _finish()


func _load_biome(sequence: StorySequence) -> void:
	var entry: BiomeEntry = BiomeEntry.new()
	entry.id = sequence.biome_id
	_biome.load(entry)
	# Biome only redraws when scrolled; one still frame is the whole picture here.
	_biome.set_scroll(0.0)


func _start_music(sequence: StorySequence) -> void:
	if sequence.music.is_empty():
		return
	var stream: AudioStreamOggVorbis = load(sequence.music) as AudioStreamOggVorbis
	if stream == null:
		printerr(&"Storyboard: failed to load music %s" % sequence.music)
		Transition.fatal_error(&"Could not load the story")
		return
	stream.loop = true
	stream.loop_offset = sequence.loop_start
	_music.stream = stream
	_music.play()


func _show_slide(slide: StorySlide, is_last_slide: bool) -> void:
	var caption_count: int = slide.captions.size()
	var caption_index: int = 0
	for caption: String in slide.captions:
		if _skip_all:
			break
		await _play_caption(caption, is_last_slide and caption_index == caption_count - 1)
		caption_index += 1


func _play_caption(caption: String, is_final: bool) -> void:
	_caption.text = "[center]%s[/center]" % caption
	_caption.visible_ratio = 0.0
	await _fade(_caption, 1.0, _CAPTION_FADE)
	if _skip_all:
		return

	var length: int = _caption.get_total_character_count()
	await _reveal(length)
	if _skip_all:
		return
	_caption.visible_ratio = 1.0

	var hold_time: float = _FINAL_HOLD if is_final else maxf(_MIN_HOLD, length * _HOLD_PER_CHAR)
	await _hold(hold_time)
	if _skip_all:
		return

	await _fade(_caption, 0.0, _CAPTION_FADE)


func _reveal(length: int) -> void:
	if length <= 0:
		return
	var plain_text: String = _caption.get_parsed_text()
	var char_delay: float = maxf(_CHAR_TIME, _MIN_REVEAL / float(length))
	for revealed: int in range(1, length + 1):
		# Checked here, not inside _wait, so a tap always jumps straight to the
		# full line rather than just shortening the character it lands on.
		if _skip_all or _skip_step:
			_skip_step = false
			return
		_caption.visible_ratio = float(revealed) / float(length)
		Sound.play_type()
		await _wait(char_delay + _pause_after(plain_text[revealed - 1]))


func _pause_after(revealed_char: String) -> float:
	if _STRONG_PUNCTUATION.contains(revealed_char):
		return _PAUSE_STRONG
	if _WEAK_PUNCTUATION.contains(revealed_char):
		return _PAUSE_WEAK
	return 0.0


func _wait(seconds: float) -> void:
	var remaining: float = seconds
	while remaining > 0.0:
		if _skip_all:
			return
		await get_tree().process_frame
		remaining -= get_process_delta_time()


func _hold(seconds: float) -> void:
	var remaining: float = seconds
	while remaining > 0.0:
		if _skip_step:
			_skip_step = false
			return
		if _skip_all:
			return
		await get_tree().process_frame
		remaining -= get_process_delta_time()


func _fade(target: CanvasItem, alpha: float, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(target, ^"modulate:a", alpha, duration)
	while tween.is_running():
		if _skip_all:
			tween.kill()
			return
		await get_tree().process_frame


func _finish() -> void:
	await Transition.go_to_menu(Transition.MenuTarget.MAIN_MENU)
