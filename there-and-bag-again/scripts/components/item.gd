@tool
class_name Item
extends Area2D

signal clicked(item)

const TILE_SIZE = 100.0

@export var data: ItemData:
	set(value):
		data = value
		if is_inside_tree() and data: 
			_apply_data()

@export var sprite: Sprite2D

# Restored dragging logic variables
var target_position: Vector2 = Vector2.ZERO 
var grab_offset: Vector2 = Vector2.ZERO

var cells: Array[Vector2i]:
	get: return data.cells if data else [] as Array[Vector2i]

func _ready() -> void:
	if data: _apply_data()

# Restored: smooths movement towards mouse + offset 
func update_target_position():
	var mouse_position = get_global_mouse_position()
	var desired_pos = mouse_position + grab_offset
	target_position += (desired_pos - target_position) / 2

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Restored: calculates offset so item doesn't snap to center of mouse 
		grab_offset = global_position - get_global_mouse_position()
		target_position = global_position
		clicked.emit(self)

func _apply_data() -> void:
	queue_redraw()
	if not data: return
	
	if not sprite: sprite = get_node_or_null("Sprite2D")
	if not sprite: return 

	if data.texture:
		sprite.texture = data.texture
		sprite.centered = false 
		
		var cell_size = _get_local_cell_size()
		var total_grid_size_px = Vector2(data.grid_size) * cell_size
		var center_offset = (total_grid_size_px - data.texture.get_size()) / 2.0
		sprite.offset = center_offset
		
		var max_grid_cells = max(data.grid_size.x, data.grid_size.y)
		var factor = (max_grid_cells * TILE_SIZE) / max(data.texture.get_width(), data.texture.get_height())
		scale = Vector2(factor, factor)

		_rebuild_colliders()

func _get_local_cell_size() -> Vector2:
	if not data or not data.texture or data.grid_size == Vector2i.ZERO:
		return Vector2.ZERO
	var max_side = max(data.texture.get_width(), data.texture.get_height())
	var max_cells = max(data.grid_size.x, data.grid_size.y)
	var size = max_side / max_cells
	return Vector2(size, size)

func _rebuild_colliders():
	for child in get_children():
		if child is CollisionShape2D: child.queue_free()
	
	var cell_size = _get_local_cell_size()
	if cell_size == Vector2.ZERO: return
	
	for cell in data.cells:
		var col = CollisionShape2D.new()
		col.shape = RectangleShape2D.new()
		col.shape.size = cell_size 
		col.position = (Vector2(cell) * cell_size) + (cell_size / 2.0)
		add_child(col)

func _draw():
	if not data: return
	var cell_size = _get_local_cell_size()
	for cell in data.cells:
		draw_rect(Rect2(Vector2(cell) * cell_size, cell_size), Color(0, 0, 0, 0.3), true)
