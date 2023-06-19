# Copyright (c) 2023 John Pennycook
# SPDX-License-Identifier: MIT
class_name UtilityAIBehavior
extends Resource
## Determines the utility of an action.
##
## A behavior has a [member name] (for debugging purposes), a list of
## [member considerations] that must be evaluated to calculate utility, and a
## value denoting the [member aggregation] process used to combine the utility
## scores calculated for each consideration.

## How utility scores should be combined.
enum AggregationType {
	PRODUCT,  ## Utility scores should be multiplied together.
	AVERAGE,  ## Utility scores should be averaged.
	MAXIMUM,  ## All utility scores except the maximum should be discarded.
	MINIMUM,  ## All utility scores except the minimum should be discarded.
}

## A descriptive name for this behavior.
## [br][br]
## [b]Note[/b]: This value is not used by the UtilityAI plugin in any way, but
## may be useful for debugging.
@export var name: StringName

## How the final utility score for this behavior should be computed from the
## utility scores for each consideration.
@export var aggregation: AggregationType = AggregationType.PRODUCT

## A list of [UtilityAIConsideration] objects that should be used to evaluate
## the utility of this behavior.
@export var considerations: Array[UtilityAIConsideration] = []


func _init(
	p_name: StringName = "",
	p_aggregation: AggregationType = AggregationType.PRODUCT,
	p_considerations: Array[UtilityAIConsideration] = []
):
	name = p_name
	aggregation = p_aggregation
	considerations = p_considerations


func _aggregate(scores: Array[float]) -> float:
	match aggregation:
		AggregationType.PRODUCT:
			return scores.reduce(func(accum, x): return accum * x)

		AggregationType.AVERAGE:
			return scores.reduce(func(accum, x): return accum + x) / len(scores)

		AggregationType.MAXIMUM:
			return scores.max()

		AggregationType.MINIMUM:
			return scores.min()

	push_error("Unrecognized AggregationType: %d" % [aggregation])
	return 0


## Calculate the utility of this behavior in the specified context.
func evaluate(context: Variant) -> float:
	var scores: Array[float] = []
	for consideration in considerations:
		var score := consideration.evaluate(context)
		scores.append(score)
	return _aggregate(scores)


func _to_string() -> String:
	return (
		"[<UtilityAIBehavior#%d>: %s, %s, %s]"
		% [self.get_instance_id(), name, aggregation, considerations]
	)
