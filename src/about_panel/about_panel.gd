# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name AboutPanel
extends PanelContainer

signal back_requested

const ABOUT_PATH: String = "res://data/assets/about.txt"

@onready var _back_button: Button = $VBox/Back
@onready var _about_text: RichTextLabel = $VBox/AboutTextl


func _ready() -> void:
	Audio.connect_menu_sounds(self)
	_load_about_text()


func _load_about_text() -> void:
	var file: FileAccess = FileAccess.open(ABOUT_PATH, FileAccess.READ)
	if file == null:
		printerr("AboutPanel: Failed to open %s !" % ABOUT_PATH)
		return

	var text: String = file.get_as_text()
	file.close()

	_about_text.text = text.replace("{build}", BuildInfo.display_string())


func _on_about_text_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))


func open() -> void:
	visible = true
	_back_button.grab_focus()


func close() -> void:
	visible = false


func _on_back_pressed() -> void:
	back_requested.emit()
