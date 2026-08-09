# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Storyboard
extends CanvasLayer

const _IMAGE_PATH: String = "res://data/assets/story/%s_%d.png"

const _CHAR_TIME: float = 0.035
const _MIN_REVEAL: float = 0.6
const _HOLD_PER_CHAR: float = 0.045
const _MIN_HOLD: float = 1.4
const _FINAL_HOLD: float = 15.0
const _CAPTION_FADE: float = 0.35
const _IMAGE_FADE: float = 0.6

@export var catalogue: StoryCatalogue

var _skip_step: bool = false
var _skip_all: bool = false

# Reassigning the texture of a visible TextureRect flashes, so the next slide
# loads into the hidden back node and the two swap roles.
var _front: TextureRect
var _back: TextureRect

@onready var _image_a: TextureRect = $ImageA
@onready var _image_b: TextureRect = $ImageB
@onready var _caption: RichTextLabel = $CaptionBox/Caption
@onready var _music: AudioStreamPlayer = $Music


func _ready() -> void:
	_front = _image_a
	_back = _image_b
	_image_a.modulate.a = 0.0
	_image_b.modulate.a = 0.0
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
		printerr("Storyboard: no sequence for id %s" % sequence_id)
		get_tree().quit()
		return

	_start_music(sequence)

	var slide_count: int = sequence.slides.size()
	var index: int = 1
	for slide: StorySlide in sequence.slides:
		if _skip_all:
			break
		await _show_slide(sequence.id, index, slide, index == slide_count)
		index += 1

	await _finish()


func _start_music(sequence: StorySequence) -> void:
	if sequence.music.is_empty():
		return
	var stream: AudioStreamOggVorbis = load(sequence.music) as AudioStreamOggVorbis
	if stream == null:
		printerr("Storyboard: failed to load music %s" % sequence.music)
		get_tree().quit()
		return
	stream.loop = true
	stream.loop_offset = sequence.loop_start
	_music.stream = stream
	_music.play()


func _show_slide(seq_id: StringName, index: int, slide: StorySlide, is_last_slide: bool) -> void:
	var path: String = _IMAGE_PATH % [seq_id, index]
	if not ResourceLoader.exists(path):
		printerr("Storyboard: missing image %s" % path)
		get_tree().quit()
		return
	var texture: Texture2D = load(path) as Texture2D
	if texture == null:
		printerr("Storyboard: failed to load image %s" % path)
		get_tree().quit()
		return
	await _swap_image(texture)

	var caption_count: int = slide.captions.size()
	var caption_index: int = 0
	for caption: String in slide.captions:
		if _skip_all:
			break
		await _play_caption(caption, is_last_slide and caption_index == caption_count - 1)
		caption_index += 1


func _swap_image(texture: Texture2D) -> void:
	_back.texture = texture
	_back.modulate.a = 0.0

	var tween: Tween = create_tween().set_parallel(true)
	if _front.texture != null:
		tween.tween_property(_front, ^"modulate:a", 0.0, _IMAGE_FADE)
	tween.tween_property(_back, ^"modulate:a", 1.0, _IMAGE_FADE)
	await tween.finished

	var previous_front: TextureRect = _front
	_front = _back
	_back = previous_front


func _play_caption(caption: String, is_final: bool) -> void:
	_caption.text = "[center]%s[/center]" % caption
	_caption.visible_ratio = 0.0
	await _fade(_caption, 1.0, _CAPTION_FADE)

	var length: int = _caption.get_total_character_count()
	var reveal_time: float = maxf(_MIN_REVEAL, length * _CHAR_TIME)
	var reveal: Tween = create_tween()
	reveal.tween_property(_caption, ^"visible_ratio", 1.0, reveal_time)
	await _wait_tween(reveal)
	_caption.visible_ratio = 1.0

	if not _skip_all:
		var hold_time: float = _FINAL_HOLD if is_final else maxf(_MIN_HOLD, length * _HOLD_PER_CHAR)
		await _hold(hold_time)

	await _fade(_caption, 0.0, _CAPTION_FADE)


func _wait_tween(tween: Tween) -> void:
	while tween.is_running():
		if _skip_step:
			_skip_step = false
			tween.kill()
			return
		await get_tree().process_frame


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
	await tween.finished


func _finish() -> void:
	await Transition.go_to_menu(Transition.MenuTarget.MAIN_MENU)
