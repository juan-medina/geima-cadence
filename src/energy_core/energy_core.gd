# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name EnergyCore
extends Node2D

@onready var _motes: CPUParticles2D = $Motes
@onready var _burst: CPUParticles2D = $Burst


func pulse() -> void:
	_burst.restart()


func stop() -> void:
	_motes.emitting = false
	_burst.emitting = false
