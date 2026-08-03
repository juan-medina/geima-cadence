# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Rank
enum Level { NONE, B, A, S }

const _GOLD: Color = Color.GOLD
const _BRONZE: Color = Color(0.65, 0.4, 0.15)
const _EMPTY: Color = Color(0.25, 0.25, 0.3)


static func from_health_percentage(health_percentage: float) -> Level:
	if health_percentage >= 0.9:
		return Level.S
	if health_percentage >= 0.7:
		return Level.A
	if health_percentage >= 0.0:
		return Level.B

	return Level.NONE


static func string(rank: Level) -> String:
	match rank:
		Level.S:
			return &"S"
		Level.A:
			return &"A"
		Level.B:
			return &"B"
	return &""


static func color(rank: Level) -> Color:
	match rank:
		Level.S:
			return _GOLD
		Level.A:
			return _BRONZE
		Level.B:
			return _BRONZE
	return _EMPTY
