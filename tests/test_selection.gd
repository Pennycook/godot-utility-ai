# Copyright (c) 2023 John Pennycook
# SPDX-License-Identifier: 0BSD
extends GutTest


func test_selection():

	var context := {
		"hp": 0.1,
		"mp": 1.0,
	}
	var Heal := preload("res://examples/behaviors/heal.tres")
	var Escape := preload("res://examples/behaviors/escape.tres")
	var options: Array[UtilityAIOption] = [
		UtilityAIOption.new(Heal, context),
		UtilityAIOption.new(Escape, context),
	]
	var decision := UtilityAI.choose_highest(options)
	assert_true(decision.behavior.name == "heal")
