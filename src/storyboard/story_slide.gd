# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name StorySlide
extends Resource

# The slide image is derived by convention from the sequence id and slide
# position (see Storyboard); only the captions are stored here.
@export var captions: PackedStringArray = PackedStringArray()
