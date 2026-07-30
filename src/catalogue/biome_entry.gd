# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name BiomeEntry
extends Resource

# Matches the bg_<id>_* asset naming and CurrentRun.biome, so the preview and
# layers are derived from it rather than stored as paths.
@export var id: int = 1

@export var name: String
@export var songs: Array[SongEntry] = []
