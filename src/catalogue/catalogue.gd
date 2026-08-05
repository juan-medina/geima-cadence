# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name Catalogue
extends Resource

@export var biomes: Array[BiomeEntry] = []


func get_biome_for_song(song_id: StringName) -> BiomeEntry:
	for biome: BiomeEntry in biomes:
		for song: SongEntry in biome.songs:
			if song.id == song_id:
				return biome

	return null


func get_song_name(song_id: StringName) -> StringName:
	for biome: BiomeEntry in biomes:
		for song: SongEntry in biome.songs:
			if song.id == song_id:
				return song.name

	return &"Unknown Song"
