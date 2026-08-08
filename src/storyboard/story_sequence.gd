# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name StorySequence
extends Resource

# The id doubles as the slide image stem: slide N loads
# res://data/assets/story/<id>_<N>.png (see Storyboard).
@export var id: StringName = &""

@export var music: String = ""

@export var loop_start: float = 0.0

@export var slides: Array[StorySlide] = []
