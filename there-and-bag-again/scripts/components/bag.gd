class_name Bag
extends Control

@export var bag_size: Vector2i = Vector2i(8,8)
var inventory_grid: Array = []


const ITEM_SCENE = preload("res://scenes/components/items/item.tscn")
const BANANA = preload("res://scenes/components/items/item_data/banana.tres")
const POTION = preload("res://scenes/components/items/item_data/potion.tres")

	
@onready var board: Node2D = $Board

func _ready() -> void:
	print("spawning!")
	_spawn(BANANA, Vector2i(0, 3))
	_spawn(BANANA, Vector2i(3, 0))
	_spawn(POTION, Vector2i(5, 3))
	

func _spawn(data: Resource, grid_pos: Vector2i) -> void:
	print("spawning!")
	var item = ITEM_SCENE.instantiate()
	item.data = data
	board.place_item(item, grid_pos)
