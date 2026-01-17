extends Node
# generates items on demand 

@export var all_items: ResourceGroup = preload("res://resources/groups/all_item_group.tres")
var item_info_by_name : Dictionary[String, ItemInfo]


func _ready() -> void:
	for item_info: ItemInfo in all_items.load_all():
		item_info_by_name[item_info.name] = item_info

func get_item_info_map() -> Dictionary[String,ItemInfo]:
	return item_info_by_name

func get_item(item_name: String) -> ItemInfo:
	return item_info_by_name[item_name]
