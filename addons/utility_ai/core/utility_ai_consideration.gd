# Copyright (c) 2023 John Pennycook
# SPDX-License-Identifier: MIT
class_name UtilityAIConsideration
extends Resource
## Describes an input variable and its impact upon utility calculations.
##
## A consideration is a mapping between an [member input_key] and the
## [member response_curve] that should be used to calculate a utility score.

## The name of the input variable, which must be the name of a property in the
## decision context that will be passed to [method evaluate].
@export var input_key: String

## Whether to invert the value (i.e., by subtracting it from 1) before
## using it to calculate utility.
@export var invert: bool

## Describes the mapping from input values to utility scores.
@export var response_curve: UtilityAIResponseCurve


func _init(
	p_input_key: String = "", p_invert: bool = false, p_response_curve = null
):
	input_key = p_input_key
	invert = p_invert
	response_curve = p_response_curve


## Calculate the utility of this consideration in the specified decision context.
func evaluate(context: Variant) -> float:
	var x: float = context.get(input_key)
	if invert:
		x = 1 - x
	return response_curve.evaluate(x)


func _to_string() -> String:
	return (
		"[<UtilityAIConsideration#%d>: %s, %s, %s]"
		% [self.get_instance_id(), input_key, invert, response_curve]
	)
