# Copyright (C) 2023 John Pennycook
# SPDX-License-Identifier: MIT
@tool
extends EditorPlugin


var response_curve_inspector = preload("res://addons/utility_ai/editor/response_curve_inspector.gd").new()


func _enter_tree():
	add_inspector_plugin(response_curve_inspector)


func _exit_tree():
	remove_inspector_plugin(response_curve_inspector)
