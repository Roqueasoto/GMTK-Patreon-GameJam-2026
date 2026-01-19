extends Node2D

@export var unified_repeat_size = Vector2(2160,0)

func _ready() -> void:
	for child: Parallax2D in get_children():
		child.repeat_size = unified_repeat_size
