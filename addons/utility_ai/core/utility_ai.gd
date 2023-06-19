# Copyright (c) 2023 John Pennycook
# SPDX-License-Identifier: MIT
class_name UtilityAI
## A plugin for building utility-based AI in Godot.
##
## A number of common functions for working with instances of other UtilityAI
## classes are provided as static functions in the UtilityAI class.


## Choose randomly between the highest-scoring options. An option is considered
## one of the highest-scoring options if it is within the specified tolerance of
## the option(s) with the maximum score.
static func choose_highest(
	options: Array[UtilityAIOption], tolerance: float = 0.0
) -> UtilityAIOption:
	# Calculate the scores for every option.
	var scores := {}
	for option in options:
		scores[option] = option.evaluate()

	# Identify the highest-scoring options by sorting them.
	options.sort_custom(func(a, b): return scores[a] < scores[b])

	# Choose randomly between all options within the specified tolerance.
	var high_score: float = scores[options[len(options) - 1]]
	var within_tolerance := func(o): return (
		absf(high_score - scores[o]) <= tolerance
	)
	return options.filter(within_tolerance).pick_random()


## Choose randomly between all options. The probability of choosing a specific
## option is based on its calculated utility.
## [br][br]
## [b]Note[/b]: This function does not require the utility values associated
## with the options to sum to 1.
static func choose_random(options: Array[UtilityAIOption]) -> UtilityAIOption:
	# Choose a random number between [0, sum)
	var sum := options.reduce(func(accum, x): return accum + x.score, 0.0)
	var rand := randf_range(0, sum)

	# Find the first value bigger than rand
	var running_total := 0.0
	for option in options:
		running_total += option.score
		if running_total >= rand:
			return option
	return options.back()


## Sample the value of the binary curve described by the optional arguments.
static func sample_binary(x: float, x_shift := 0.0, y_shift := 0.0) -> float:
	var threshold := clampf(0.5 + x_shift, 0.0, 1.0)
	var lo := clampf(0.0 + y_shift, 0.0, 1.0)
	var hi := clampf(1.0 + y_shift, 0.0, 1.0)
	if x < threshold and not is_equal_approx(x, threshold):
		return lo
	return hi


## Sample the value of the linear curve described by the optional arguments.
static func sample_linear(
	x: float, x_shift := 0.0, y_shift := 0.0, slope := 1
) -> float:
	return clampf(slope * (x - x_shift) + y_shift, 0.0, 1.0)


## Sample the value of the exponential curve described by the optional arguments.
static func sample_exponential(
	x: float, x_shift := 0.0, y_shift := 0.0, slope := 1, exponent := 2
) -> float:
	return clampf(slope * pow(x - x_shift, exponent) + y_shift, 0.0, 1.0)


## Sample the value of the logistic curve described by the optional arguments.
static func sample_logistic(
	x: float, x_shift := 0.0, y_shift := 0.0, slope := 1, exponent := 1
) -> float:
	return clampf(
		slope / (1.0 + exp(-exponent * (x - 0.5 - x_shift))) + y_shift, 0.0, 1.0
	)
