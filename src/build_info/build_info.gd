# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name BuildInfo
extends CanvasLayer

const INFO_PATH: String = "res://build_info/build_info.json"
const DEV_BUILD: String = "dev"

var version: String = ""
var commit: String = ""
var built_at: String = ""

@onready var _label: Label = $Label


func _ready() -> void:
	version = ProjectSettings.get_setting("application/config/version", "0.0.0")
	_load_build_info()
	_label.text = display_string()


# A build is identified by the commit it was made from, so the stamp is written
# at build time by scripts/gen_build_info.py and is empty in a working tree.
func display_string() -> String:
	if commit.is_empty() or built_at.is_empty():
		return "v%s (%s)" % [version, DEV_BUILD]
	return "v%s+%s.%s" % [version, built_at, commit]


func _load_build_info() -> void:
	var file: FileAccess = FileAccess.open(INFO_PATH, FileAccess.READ)
	if file == null:
		printerr("BuildInfo: Failed to open %s !" % INFO_PATH)
		return

	var text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var err: Error = json.parse(text)
	if err != OK:
		printerr(
			(
				"BuildInfo: Failed to parse %s at line %d: %s !"
				% [INFO_PATH, json.get_error_line(), json.get_error_message()]
			)
		)
		return

	var data: Dictionary = json.data
	commit = _read_string(data, "commit")
	built_at = _read_string(data, "built_at")


func _read_string(data: Dictionary, key: String) -> String:
	var value: Variant = data.get(key, "")
	if value is String:
		return value
	return ""
