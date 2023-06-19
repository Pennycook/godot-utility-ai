# Copyright (c) 2023 John Pennycook
# SPDX-License-Identifier: 0BSD
class_name UtilityContext
extends Resource

## A simple [Dictionary] wrapper suitable for use as a decision context.
##
## This class is a simple example of one way to create a [Resource] that can
## be used as a decision context for the UtilityAI plugin.


## Stores a mapping from input keys to input values.
@export var data: Dictionary = {}


func _init(p_data = null):
	data = p_data


func _get(property: StringName) -> Variant:

	if property == "data":
		return null

	if not data.has(property):
		push_error("Key %s does not exist in UtilityContext." % [property])
		return 0

	return data[property]


func _set(property: StringName, value: Variant) -> bool:

	if property == "data":
		return false

	if not data.has(property):
		push_warning("Key %s did not previously exist in UtilityContext." % [property])

	data[property] = value
	return true
