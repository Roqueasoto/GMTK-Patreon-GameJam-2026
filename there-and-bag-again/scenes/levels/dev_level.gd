extends Node2D

# 1. Load the GENERIC Item Scene (The one with Item.gd attached)
# Make sure this path points to your saved "Item.tscn"
const ITEM_SCENE = preload("res://scenes/components/items/item.tscn")

# 2. Load the DATA Resources (The "Stats")
# Make sure these point to your .tres files
const BANANA_DATA = preload("res://scenes/components/items/item_data/banana.tres")
const POTION_DATA = preload("res://scenes/components/items/item_data/potion.tres")

func _ready() -> void:
	# --- Spawn Item 1 ---
	var item1 = ITEM_SCENE.instantiate()
	item1.data = BANANA_DATA  # <--- Assigning data triggers the texture/colliders!
	
	# Verify the Board node exists at this path
	var board = $Bag/Board 
	board.place_item(item1, Vector2i(0, 3))
	var item2 = ITEM_SCENE.instantiate()
	item2.data = BANANA_DATA  # <--- Assigning data triggers the texture/colliders!
	board.place_item(item2, Vector2i(3, 0))
	
	var potion_item = ITEM_SCENE.instantiate()
	potion_item.data = POTION_DATA  # <--- Assigning data triggers the texture/colliders!
	board.place_item(potion_item, Vector2i(5, 3))
	
	# --- Spawn Item 2 (Example) ---
	# var item2 = ITEM_SCENE.instantiate()
	# item2.data = BANANA_DATA # Reuse the same data, or use BANANA_DATA
	# board.place_item(item2, Vector2i(4, 4))

func _process(delta: float) -> void:
	pass
