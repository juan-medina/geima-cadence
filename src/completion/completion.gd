# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Completion
enum State { NONE, ESCAPED, MASTERING, MASTERED }

const _GOLD: Color = Color.GOLD
const _BRONZE: Color = Color(0.65, 0.4, 0.15)
const _EMPTY: Color = Color(0.25, 0.25, 0.3)


static func from(ranks: Array[Rank.Level]) -> State:
	var s_count: int = 0
	var escaped: bool = false
	for rank: Rank.Level in ranks:
		if rank != Rank.Level.NONE:
			escaped = true
		if rank == Rank.Level.S:
			s_count += 1

	if s_count > 0 and s_count == ranks.size():
		return State.MASTERED
	if s_count > 0:
		return State.MASTERING
	if escaped:
		return State.ESCAPED
	return State.NONE


static func string(state: State) -> String:
	match state:
		State.ESCAPED:
			return &"ESCAPED"
		State.MASTERING:
			return &"MASTERING"
		State.MASTERED:
			return &"MASTERED"
	return &""


static func color(state: State) -> Color:
	match state:
		State.MASTERED:
			return _GOLD
		State.MASTERING:
			return _BRONZE
		State.ESCAPED:
			return _BRONZE
	return _EMPTY
