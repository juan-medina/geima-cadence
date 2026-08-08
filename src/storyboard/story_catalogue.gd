# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name StoryCatalogue
extends Resource

@export var intro: StorySequence
@export var escape: StorySequence
@export var secret: StorySequence


func sequence_for(id: StringName) -> StorySequence:
	match id:
		&"intro":
			return intro
		&"escape":
			return escape
		&"secret":
			return secret
	return null
