# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name StorySequence
extends Resource

@export var id: StringName = &""

# Biome (see biomes.json) rendered behind this sequence's captions.
@export var biome_id: int = 0

@export var music: String = ""

@export var loop_start: float = 0.0

@export var slides: Array[StorySlide] = []
