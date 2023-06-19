# Copyright (c) 2023 John Pennycook
# SPDX-License-Identifier: 0BSD
extends GutTest


func test_aggregation():
	var consideration1 := UtilityAIConsideration.new(
		"hp",
		true,
		UtilityAIResponseCurve.new(UtilityAIResponseCurve.CurveType.EXPONENTIAL)
	)
	var consideration2 := UtilityAIConsideration.new(
		"mp",
		false,
		UtilityAIResponseCurve.new(UtilityAIResponseCurve.CurveType.LINEAR)
	)
	var action := UtilityAIBehavior.new(
		"heal",
		UtilityAIBehavior.AggregationType.PRODUCT,
		[consideration1, consideration2]
	)
	var context := {
		"hp": 0.5,
		"mp": 0.5,
	}
	var score := action.evaluate(context)
	assert_true(is_equal_approx(score, pow(0.5, 2) * 0.5))
