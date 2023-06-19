# Copyright (c) 2023 John Pennycook
# SPDX-License-Identifier: 0BSD
extends Label


func _on_state_changed(state: Agent.State) -> void:
	match state:
		Agent.State.EATING:
			text = "Eat"
		Agent.State.SLEEPING:
			text = "Sleep"
		Agent.State.WATCHING_TV:
			text = "Watch TV"
