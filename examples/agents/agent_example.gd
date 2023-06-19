# Copyright (c) 2023 John Pennycook
# SPDX-License-Identifier: 0BSD
extends Node


func _ready():
	var needs: AgentNeeds = $Agent.needs
	needs.food_changed.connect(%FoodBar._on_needs_changed)
	needs.fun_changed.connect(%FunBar._on_needs_changed)
	needs.energy_changed.connect(%EnergyBar._on_needs_changed)

	$Agent.state_changed.connect(%StateLabel._on_state_changed)
