# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Endings
enum Kind { NONE, ESCAPE, SECRET }

const ESCAPE_ID: StringName = &"escape"
const SECRET_ID: StringName = &"secret"


static func song_states(catalogue: Catalogue) -> Array[Completion.State]:
	var states: Array[Completion.State] = []
	for biome: BiomeEntry in catalogue.biomes:
		for song: SongEntry in biome.songs:
			var ranks: Array[Rank.Level] = []
			for diff: int in Track.DifficultType.values():
				ranks.append(GameData.get_star_record(song.id, diff as Track.DifficultType))
			states.append(Completion.from_ranks(ranks))
	return states


static func escape_threshold(states: Array[Completion.State]) -> bool:
	if states.is_empty():
		return false
	for state: Completion.State in states:
		if state == Completion.State.ESCAPING:
			return false
	return true


static func secret_threshold(states: Array[Completion.State]) -> bool:
	if states.is_empty():
		return false
	for state: Completion.State in states:
		if state != Completion.State.MASTERED:
			return false
	return true
