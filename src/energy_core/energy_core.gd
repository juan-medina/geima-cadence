# SPDX-FileCopyrightText: 2026 Juan Medina
# SPDX-License-Identifier: MIT

class_name EnergyCore
extends Node2D

@onready var _burst: CPUParticles2D = $Burst


func pulse() -> void:
	_burst.restart()
