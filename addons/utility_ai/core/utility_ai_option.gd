# Copyright (c) 2023 John Pennycook
# SPDX-License-Identifier: MIT
@tool
class_name UtilityAIOption
extends Resource
## Describes a single option to evaluate.
##
## An option pairs a [member behavior] with the specific decision
## [member context] in which it should be evaluated. An option can also store
## an optional [member action] that should be triggered in the event that this
## option is chosen.

## The behavior that will drive the evaluation of this option's utility.
@export var behavior: UtilityAIBehavior

## The specific decision context that should be used to evaluate this option.
## [br][br]
## [b]Note[/b]: Anything can be used as a decision context, as long as it
## provides a [code]get()[/code] method that allows considerations to look-up
## the values of input values. Common examples include: a [Resource]
## describing an agent's state, or a [Dictionary] mapping input keys to input
## values.
var context: Variant

## An optional value describing any action(s) that should be triggered in the
## event that this option is chosen.
## [br][br]
## [b]Note[/b]: This variable is not used by the plugin, but can be used to
## associate a [UtilityAIOption] with an action. Anything can be used as an
## action, but common examples include: a [Callable] that directly affects
## gameplay, a [Dictionary] of values to pass to some other function, or a
## [Resource] describing the chosen action.
var action: Variant


func _init(
	p_behavior: UtilityAIBehavior = null,
	p_context: Variant = null,
	p_action: Variant = null
):
	behavior = p_behavior
	context = p_context
	action = p_action


## Calculate the utility of this option, using [member behavior] and
## [member context]. Equivalent to calling:
## [code]behavior.evaluate(context)[/code].
func evaluate() -> float:
	return behavior.evaluate(context)


func _to_string() -> String:
	return (
		"[<UtilityAIOption#%d>: %s, %s, %s]"
		% [self.get_instance_id(), action, behavior, context]
	)


# The fake "action_type" property exposed by _set, _get and _get_property_list()
# is a workaround for the lack of Inspector support for editing Variant
func _set(property: StringName, value: Variant) -> bool:
	if property == "action_type":
		match value:
			TYPE_NIL:
				action = null
			TYPE_STRING:
				action = String()
			TYPE_OBJECT:
				action = Object.new()
			TYPE_DICTIONARY:
				action = Dictionary()
			TYPE_ARRAY:
				action = Array()
		notify_property_list_changed()
		return true
	return false


func _get(property: StringName) -> Variant:
	if property == "action_type":
		return typeof(action)
	return null


func _get_property_list():
	var properties = []
	properties.append(
		{
			"name": "action_type",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_EDITOR,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "Variant:0,String:4,Object:24,Dictionary:27,Array:28"
		}
	)
	properties.append(
		{
			"name": "action",
			"type": get("action_type"),
			"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_NIL_IS_VARIANT,
			"hint": PROPERTY_HINT_NONE,
		}
	)
	return properties
