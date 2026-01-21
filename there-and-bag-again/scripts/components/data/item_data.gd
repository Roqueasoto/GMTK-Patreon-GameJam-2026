class_name ItemData 
extends Resource

@export var id: String            # Unique Identifier - 1:1 with event
@export var display_name: String
@export var texture: Texture2D
@export var grid_size: Vector2i = Vector2i(5, 5) # <--- ADD THIS LINE
@export var cells: Array[Vector2i] = [Vector2i(0, 0)]
@export var properties: Array[Utils.property]
