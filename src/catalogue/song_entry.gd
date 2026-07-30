# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name SongEntry
extends Resource

# Stem shared by the song's assets/package (e.g. "<id>.pck"), so it stays
# format-agnostic for the packaging pipeline.
@export var id: StringName

@export var name: String
@export var bpm: int = 0
