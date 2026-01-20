extends Node2D

@export var player_displacement = 6.0

func _process(_delta) -> void:
	position.x += player_displacement
