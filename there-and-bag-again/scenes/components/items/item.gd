@tool
class_name ItemTool
extends Node2D

const TILE_SIZE := 100.0

@export var data: ItemData:
	set(value):
		data = value
		if is_node_ready(): _update_visuals()

var grab_offset := Vector2.ZERO

var cells: Array[Vector2i]:
	get: return data.cells if data else []

func _ready() -> void:
	_update_visuals()

func _update_visuals() -> void:
	if not data or not data.texture: return
	
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if not sprite:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		add_child(sprite)

	sprite.texture = data.texture
	sprite.centered = false
	sprite.z_index = 1 # Force sprite to a higher layer than the _draw() content (shadows)
	
	# Calculate scaling to fit texture within grid cells
	var max_grid_cells := maxf(data.grid_size.x, data.grid_size.y)
	var max_tex_size := maxf(data.texture.get_width(), data.texture.get_height())
	var scale_factor := (max_grid_cells * TILE_SIZE) / max_tex_size
	
	scale = Vector2(scale_factor, scale_factor)
	
	# Center the sprite visually within the grid bounds
	var total_grid_px := Vector2(data.grid_size) * (TILE_SIZE / scale_factor)
	sprite.offset = (total_grid_px - data.texture.get_size()) / 2.0
	
	queue_redraw()

# Optional: Keep only if you need visual debugging of grid cells
func _draw() -> void:
	if not data: return
	# This runs at the Node's base Z-index (0), placing it below the sprite (1)
	var local_cell_size := Vector2(TILE_SIZE, TILE_SIZE) / scale.x
	for cell in data.cells:
		draw_rect(Rect2(Vector2(cell) * local_cell_size, local_cell_size), Color(0, 0, 0, 0.3))
