class_name ItemInfo
extends Resource


@export var name: String    # Unique - used to id assets from saves & loads
@export var icon_texture: Texture2D
@export var layout: Array   # 2D Array of booleans, which determine item shape.
@export var properties: Array[Utils.property]
