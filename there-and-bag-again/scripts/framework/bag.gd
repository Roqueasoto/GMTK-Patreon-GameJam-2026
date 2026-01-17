class_name Bag
extends Node2D

@export var bag_size: Vector2i = Vector2i(8,8)
var inventory_grid: Array = []

func _ready() -> void:
	# Create bag_sized grid
	for x in range(bag_size.x):
		inventory_grid.append([])
		for y in range(bag_size.y):
			inventory_grid[x].append([])
