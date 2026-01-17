class_name Item
extends Node2D

@export var sprite: Sprite2D
@export var collider: CollisionShape2D
var info: ItemInfo

func _ready() -> void:
	sprite.texture = info.texture
	collider.shape = info.collision_shape
