# Copyright (c) 2023 John Pennycook
# SPDX-License-Identifier: 0BSD
extends GutTest

# Lists of curve parameters to test.
# Prepared by _ready() before calling any tests.
var binary_params = []
var linear_params = []
var exponential_params = []
var logistic_params = []

# Configure the number of tests.
# Remember that the number of combinations here grows very quickly...
const nx := 10
const ny := 10
const ns := 5
const ne := 5


func _ready():
	var binary_values := []
	var linear_values := []
	var exponential_values = []

	for i in range(0, nx + 1):
		var xs := -1.0 + i * (2.0 / nx)
		for j in range(0, ny + 1):
			var ys := -1.0 + j * (2.0 / ny)
			binary_values.append([xs, ys])
			for k in range(1, ns):
				var slope := k
				linear_values.append([xs, ys, slope])
				for m in range(1, ne):
					var exponent := m
					exponential_values.append([xs, ys, slope, exponent])

	binary_params = (
		ParameterFactory
		. named_parameters(
			["xs", "ys"],
			binary_values,
		)
	)

	linear_params = (
		ParameterFactory
		. named_parameters(
			["xs", "ys", "slope"],
			linear_values,
		)
	)

	exponential_params = (
		ParameterFactory
		. named_parameters(
			["xs", "ys", "slope", "exp"],
			exponential_values,
		)
	)

	logistic_params = exponential_params


func valid_response_curve(
	curve: UtilityAIResponseCurve, function: Callable
) -> bool:
	const nvalues := 10
	var step = 1.0 / float(nvalues)
	for i in range(0, nvalues):
		var x := float(i * step)
		var utility := curve.evaluate(x)
		if not is_equal_approx(utility, function.call(x)):
			return false
	return true


func test_binary_response_curve(params = use_parameters(binary_params)) -> void:
	var x_shift: float = params.xs
	var y_shift: float = params.ys
	var args := {
		"x_shift": x_shift,
		"y_shift": y_shift,
	}
	var curve := UtilityAIResponseCurve.new(
		UtilityAIResponseCurve.CurveType.BINARY, args
	)
	var binary = func(x: float) -> float:
		return UtilityAI.sample_binary(x, x_shift, y_shift)
	assert_true(valid_response_curve(curve, binary))


func test_linear_response_curve(params = use_parameters(linear_params)) -> void:
	var x_shift: float = params.xs
	var y_shift: float = params.ys
	var slope: int = params.slope
	var args := {
		"x_shift": x_shift,
		"y_shift": y_shift,
		"slope": slope,
	}
	var curve := UtilityAIResponseCurve.new(
		UtilityAIResponseCurve.CurveType.LINEAR, args
	)
	var linear = func(x: float) -> float:
		return UtilityAI.sample_linear(x, x_shift, y_shift, slope)
	assert_true(valid_response_curve(curve, linear))


func test_exponential_response_curve(
	params = use_parameters(exponential_params)
) -> void:
	var x_shift: float = params.xs
	var y_shift: float = params.ys
	var slope: int = params.slope
	var exponent: int = params.exp
	var args := {
		"x_shift": x_shift,
		"y_shift": y_shift,
		"slope": slope,
		"exponent": exponent,
	}
	var curve := UtilityAIResponseCurve.new(
		UtilityAIResponseCurve.CurveType.EXPONENTIAL, args
	)
	var exponential = func(x: float) -> float:
		return UtilityAI.sample_exponential(x, x_shift, y_shift, slope, exponent)
	assert_true(valid_response_curve(curve, exponential))


func test_logistic_response_curve(
	params = use_parameters(logistic_params)
) -> void:
	var x_shift: float = params.xs
	var y_shift: float = params.ys
	var slope: int = params.slope
	var exponent: int = params.exp
	var args := {
		"x_shift": x_shift,
		"y_shift": y_shift,
		"slope": slope,
		"exponent": exponent,
	}
	var curve := UtilityAIResponseCurve.new(
		UtilityAIResponseCurve.CurveType.LOGISTIC, args
	)
	var logistic = func(x: float) -> float:
		return UtilityAI.sample_logistic(x, x_shift, y_shift, slope, exponent)
	assert_true(valid_response_curve(curve, logistic))


func test_custom_response_curve() -> void:
	var custom_curve := Curve.new()
	custom_curve.add_point(
		Vector2(0.0, 0.0), 0, 2, Curve.TANGENT_FREE, Curve.TANGENT_LINEAR
	)
	custom_curve.add_point(
		Vector2(0.5, 1.0), 2, 0, Curve.TANGENT_LINEAR, Curve.TANGENT_LINEAR
	)
	custom_curve.add_point(
		Vector2(1.0, 1.0), 0, 0, Curve.TANGENT_LINEAR, Curve.TANGENT_FREE
	)
	var custom_function = func(x: float) -> float:
		if x < 0.5:
			return 2 * x
		else:
			return 1

	var curve := UtilityAIResponseCurve.new(
		UtilityAIResponseCurve.CurveType.CUSTOM, custom_curve
	)
	assert_true(valid_response_curve(curve, custom_function))
