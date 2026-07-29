# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name BigTextPanel
extends RichTextLabel

signal load_failed(message: String)

const SCROLL_SPEED: float = 500.0


func _ready() -> void:
	set_process(is_visible_in_tree())


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		set_process(is_visible_in_tree())


func _process(delta: float) -> void:
	var scroll_input: float = Input.get_axis(&"ui_up", &"ui_down")
	if absf(scroll_input) > 0.1:
		get_v_scroll_bar().value += scroll_input * SCROLL_SPEED * delta


func load_file(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		printerr("BigTextPanel: Failed to open %s !" % path)
		load_failed.emit("Failed to open %s" % path)
		return

	# {build} is a placeholder in the text files, filled with the build stamp.
	text = file.get_as_text().replace("{build}", BuildInfo.display_string())
	file.close()


func _on_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
