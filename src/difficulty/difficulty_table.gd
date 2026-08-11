# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name DifficultyTable
extends Resource

@export var easy: DifficultyProfile
@export var normal: DifficultyProfile
@export var hard: DifficultyProfile


func profile_for(difficulty: Track.DifficultType) -> DifficultyProfile:
	match difficulty:
		Track.DifficultType.EASY:
			return easy
		Track.DifficultType.NORMAL:
			return normal
		Track.DifficultType.HARD:
			return hard
	return null
