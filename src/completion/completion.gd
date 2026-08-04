# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Completion
enum State { ESCAPING, ESCAPED, MASTERING, MASTERED }

const _GOLD: Color = Color.GOLD
const _BRONZE: Color = Color(0.65, 0.4, 0.15)
const _GREEN: Color = Color(0.4, 0.75, 0.45)
const _EMPTY: Color = Color(0.25, 0.25, 0.3)


static func from_ranks(ranks: Array[Rank.Level]) -> State:
	var escaped: bool = false
	var mastered_count: int = 0
	for rank: Rank.Level in ranks:
		if rank != Rank.Level.NONE:
			escaped = true
		if rank == Rank.Level.S:
			mastered_count += 1
	return _derive(escaped, mastered_count, ranks.size())


static func from_states(states: Array[State]) -> State:
	var escaped_count: int = 0
	var mastered_count: int = 0
	for state: State in states:
		if state != State.ESCAPING:
			escaped_count += 1
		if state == State.MASTERED:
			mastered_count += 1
	var all_escaped: bool = states.size() > 0 and escaped_count == states.size()
	var state: State = _derive(all_escaped, mastered_count, states.size())
	if state == State.ESCAPED:
		return State.MASTERING
	return state


static func _derive(escaped: bool, mastered_count: int, total: int) -> State:
	if total > 0 and mastered_count == total:
		return State.MASTERED
	if mastered_count > 0:
		return State.MASTERING
	if escaped:
		return State.ESCAPED
	return State.ESCAPING


static func string(state: State) -> String:
	match state:
		State.ESCAPING:
			return &"ESCAPING"
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
			return _GREEN
		State.ESCAPING:
			return _EMPTY
	return _EMPTY
