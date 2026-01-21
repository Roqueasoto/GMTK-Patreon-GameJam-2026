class_name Bag
extends Control

# Preload resources to use for both spawning and the registry
const ITEM_SCENE = preload("res://scenes/components/items/item.tscn")
const BANANA = preload("res://scenes/components/items/item_data/banana.tres")
const POTION = preload("res://scenes/components/items/item_data/potion.tres")

# Use 'Board' type now that class_name is added to Board.gd
@onready var board: Board = $Board

func _ready() -> void:
	# Populate the registry so Board knows what "banana" means when GameEvent fires
	board.item_registry["banana"] = BANANA
	board.item_registry["potion"] = POTION
	
	print("Bag Initialized. Registry: ", board.item_registry.keys())

func _spawn(data: Resource, grid_pos: Vector2i) -> void:
	# Manual spawn logic for setup
	var item = ITEM_SCENE.instantiate()
	item.data = data
	board.place_item(item, grid_pos)
