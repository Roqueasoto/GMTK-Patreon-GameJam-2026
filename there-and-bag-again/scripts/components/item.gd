class_name Item
extends Node2D

@export var sprite: Sprite2D
@export var collider: CollisionShape2D
@export var layout: Array   # 2D Array of booleans, which determine item shape.
@export var properties: Array[Utils.property]

var info: ItemInfo

# Need a way to generate item from item infos
func _ready() -> void:
	# Load icon from path into
	pass
