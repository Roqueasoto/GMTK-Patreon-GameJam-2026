@tool
extends EditorInspectorPlugin

#var GridPropertyScript = preload("res://addons/gridplugin/GridEditorProperty.gd")
var GridPropertyScript = preload("res://addons/gridplugin/GridEditorProperty.gd")

func _can_handle(object):
	return object is ItemData

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name == "cells":
		add_property_editor(name, GridPropertyScript.new())
		return true # Tell Godot we handled this property
	return false
