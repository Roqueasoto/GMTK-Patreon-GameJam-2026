class_name Bag
extends Control

const ITEM_SCENE = preload("res://scenes/components/items/item.tscn")
const ITEMS_PATH = "res://resources/item_data/"

@onready var board: Board = $Board

func _ready() -> void:
	_load_items_into_registry()
	print("Bag Initialized. Registry: ", board.item_registry.keys())

func _load_items_into_registry() -> void:
	var dir = DirAccess.open(ITEMS_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var resource = load(ITEMS_PATH + file_name)
				# Use the file name (without extension) as the registry key
				var key = file_name.get_basename()
				board.item_registry[key] = resource
			
			file_name = dir.get_next()
	else:
		push_error("Failed to access path: " + ITEMS_PATH)

func _spawn(data: Resource, grid_pos: Vector2i) -> void:
	var item = ITEM_SCENE.instantiate()
	item.data = data
	board.place_item(item, grid_pos)
