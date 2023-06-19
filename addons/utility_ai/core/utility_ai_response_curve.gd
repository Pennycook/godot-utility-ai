# Copyright (c) 2023 John Pennycook
# SPDX-License-Identifier: MIT
@tool
class_name UtilityAIResponseCurve
extends Curve
## A curve used to calculate utility from a value.
##
## A [UtilityAIResponseCurve] describes a relationship between a normalized
## input value (i.e., an input value in the range [i][0, 1][/i]) and the desired
## utility value.
## [br][br]
## The response curve is stored as a sequence of points managed by [Curve], and
## can therefore represent any arbitrary piecewise function. For convenience, a
## number of built-in curves that are typically used in utility systems
## (binary, linear, exponential and logistic curve) are also available.
## [br][br]
## The utility value associated with a given input value can be calculated by
## calling the [method evaluate] method.
## [br][br]
## [b]Warning[/b]: Although the [method sample] method inherited from [Curve]
## may also be used to calculate utility, this is not recommended. In a future
## version of the plugin, the behavior of these functions may not be identical.

## Whether this curve is one of several built-in types, or a custom curve.
enum CurveType {
	BINARY,  ## A curve that is 0 until a threshold, then 1 afterwards.
	LINEAR,  ## A straight line between two points.
	EXPONENTIAL,  ## A simple curve with x raised to the specified power.
	LOGISTIC,  ## An S-shaped curve, similar to a smoothed binary curve.
	CUSTOM,  ## A custom [Curve] described by a sequence of points.
}

## The type of the curve, as represented by an [enum CurveType].
@export var curve_type: CurveType = CurveType.CUSTOM:
	set = _set_curve_type

## The exponent of the curve (if applicable).
@export_range(1, 100) var exponent: int = 1:
	set(value):
		exponent = value
		_update_points()

## The slope of the curve (if applicable).
@export_range(0, 100) var slope: int = 1:
	set(value):
		slope = value
		_update_points()

## The amount to shift the curve along the x-axis.
@export_range(-1.0, +1.0) var x_shift: float = 0.0:
	set(value):
		x_shift = value
		_update_points()

## The amount to shift the curve along the y-axis.
@export_range(-1.0, +1.0) var y_shift: float = 0.0:
	set(value):
		y_shift = value
		_update_points()

var _ignore_changed := false


func _is_utility_ai_response_curve():
	pass


func _init(p_curve_type: CurveType = CurveType.CUSTOM, arg: Variant = null):
	changed.connect(_on_changed)

	curve_type = p_curve_type
	match p_curve_type:
		CurveType.CUSTOM:
			if arg != null:
				if not arg is Curve:
					push_error("For CUSTOM curve, arg must be a Curve")
				else:
					_data = arg._data
		_:
			if arg != null:
				if not arg is Dictionary:
					push_error("For non-CUSTOM curve, arg must be a Dictionary")
				else:
					if "exponent" in arg:
						exponent = arg.get("exponent")
					if "slope" in arg:
						slope = arg.get("slope")
					if "x_shift" in arg:
						x_shift = arg.get("x_shift")
					if "y_shift" in arg:
						y_shift = arg.get("y_shift")


func _set_curve_type(p_curve_type: CurveType):
	curve_type = p_curve_type
	notify_property_list_changed()

	exponent = 1
	slope = 1
	x_shift = 0.0
	y_shift = 0.0

	match curve_type:
		CurveType.EXPONENTIAL:
			exponent = 2
		CurveType.LOGISTIC:
			exponent = 10

	_update_points()


func _clamp(x: float) -> float:
	return clampf(x, 0.0, 1.0)


func _add_points(f: Callable, npoints: int = 10) -> void:
	for i in range(0, npoints + 1):
		var x := float(i) / npoints
		var y := f.call(x)
		add_point(
			Vector2(x, y), 0, 0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR
		)


func _update_points(npoints: int = 10) -> void:
	if curve_type == CurveType.CUSTOM:
		return

	_ignore_changed = true

	clear_points()

	if curve_type == CurveType.BINARY:
		var threshold := _clamp(0.5 + x_shift)
		var lo := _clamp(0.0 + y_shift)
		var hi := _clamp(1.0 + y_shift)
		if threshold == 0:
			add_point(Vector2(0, hi))
			add_point(Vector2(1, hi))
		else:
			# This ordering of add_point() is required for correct behavior.
			# Godot otherwise inverts the order of points 2 and 3.
			add_point(Vector2(0, lo))
			add_point(Vector2(threshold, hi))
			add_point(Vector2(threshold, lo))
			add_point(Vector2(1, hi))
	elif curve_type == CurveType.LINEAR:
		var linear = func(x): return _clamp(slope * (x - x_shift) + y_shift)
		_add_points(linear, npoints)
	elif curve_type == CurveType.EXPONENTIAL:
		var exponential = func(x): return _clamp(
			slope * pow(x - x_shift, exponent) + y_shift
		)
		_add_points(exponential, npoints)
	elif curve_type == CurveType.LOGISTIC:
		var logistic = func(x): return _clamp(
			slope / (1.0 + exp(-exponent * (x - 0.5 - x_shift))) + y_shift
		)
		_add_points(logistic, npoints)

	_ignore_changed = false


func _on_changed() -> void:
	if _ignore_changed:
		return
	if curve_type != CurveType.CUSTOM:
		_set_curve_type(CurveType.CUSTOM)


## Returns the utility value for the input value [code]x[/code].
func evaluate(x: float) -> float:
	return super.sample(x)


func _to_string() -> String:
	const NAMES := {
		CurveType.BINARY: "BINARY",
		CurveType.LINEAR: "LINEAR",
		CurveType.EXPONENTIAL: "EXPONENTIAL",
		CurveType.LOGISTIC: "LOGISTIC",
		CurveType.CUSTOM: "CUSTOM",
	}

	if curve_type == CurveType.CUSTOM:
		return (
			"[<UtilityAIResponseCurve#%d>: %s]"
			% [self.get_instance_id(), "CUSTOM"]
		)

	var name: String = NAMES[curve_type]
	var fmt := "[<UtilityAIResponseCurve#%d>: %s, (%d, %d, %f, %f)]"
	return (
		fmt % [self.get_instance_id(), name, exponent, slope, x_shift, y_shift]
	)
