# Copyright (c) 2023 John Pennycook
# SPDX-License-Identifier: 0BSD
class_name AgentNeeds
extends Resource


signal food_changed(value)
signal fun_changed(value)
signal energy_changed(value)


@export var food := 0.5 : set = _set_food
@export var fun := 0.5 : set = _set_fun
@export var energy := 0.5 : set = _set_energy


func _set_food(p_food: float) -> void:
	food = clamp(p_food, 0.0, 1.0)
	food_changed.emit(food)


func _set_fun(p_fun: float) -> void:
	fun = clamp(p_fun, 0.0, 1.0)
	fun_changed.emit(fun)


func _set_energy(p_energy: float) -> void:
	energy = clamp(p_energy, 0.0, 1.0)
	energy_changed.emit(energy)
