class_name Bag
extends Control

const ITEM_SCENE = preload("res://scenes/components/items/item.tscn")
@export var all_items: ResourceGroup = preload("res://resources/groups/all_items.tres")

@onready var board: Board = $Board

func _ready() -> void:
	_load_items_into_registry()
	print("Bag Initialized. Registry: ", board.item_registry.keys())

func _load_items_into_registry() -> void:
	for item : ItemData in all_items.load_all():
		board.item_registry[item.id] = item

func _spawn(data: Resource, grid_pos: Vector2i) -> void:
	var item = ITEM_SCENE.instantiate()
	item.data = data
	board.place_item(item, grid_pos)
