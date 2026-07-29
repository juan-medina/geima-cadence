# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name EulaScreen
extends CanvasLayer

const EULA_PATH: String = "res://data/assets/eula.txt"

@onready var _eula_text: BigTextPanel = $Center/EulaPanel/VBox/EulaText
@onready var _accept_button: Button = $Center/EulaPanel/VBox/Buttons/Accept


func _ready() -> void:
	Audio.connect_menu_sounds(self)
	if Options.is_eula_accepted(_eula_version()):
		Transition.go_to_menu_instant()
		return

	_eula_text.load_file(EULA_PATH)
	Audio.grab_focus_silent(_accept_button)


# Acceptance is keyed to the major.minor version so a patch release does not
# force the player to agree again, but a minor bump (a changed EULA) does.
func _eula_version() -> String:
	var parts: PackedStringArray = BuildInfo.version.split(".")
	if parts.size() >= 2:
		return "%s.%s" % [parts[0], parts[1]]
	return BuildInfo.version


func _on_accept_pressed() -> void:
	Options.eula_accepted_version = _eula_version()
	await Transition.go_to_menu()


func _on_decline_pressed() -> void:
	# quit() cannot close a browser tab, so on web we leave the game instead.
	if OS.has_feature(&"web"):
		JavaScriptBridge.eval("window.location.href = 'about:blank';")
		return

	get_tree().quit()
