class_name Item
extends Node2D

@export var sprite: Sprite2D
@export var collider: CollisionShape2D
var info: ItemInfo

# Need a way to generate item from item infos
func _ready() -> void:
	sprite.texture = info.texture
	collider.shape = info.collision_shape
	# Load icon from path into
	pass
