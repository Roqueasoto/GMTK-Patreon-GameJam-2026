class_name ItemInfo
extends Resource

@export var name: String    # Unique
@export var texture: Texture2D
@export var collision_shape: ConvexPolygonShape2D
@export var layout: Array   # 2D Array of booleans, which determine item shape.
@export var properties: Array[Utils.property]
