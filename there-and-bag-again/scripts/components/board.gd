extends Node2D

@export var tile_size := 100
@export var grid_width := 8
@export var grid_height := 8

var grid_data: Dictionary = {}
var selected_item: Item = null

func _ready():
	grid_data.clear()

func grid_to_pixel(grid_pos: Vector2i) -> Vector2:
	return Vector2(grid_pos.x * tile_size, grid_pos.y * tile_size)

func place_item(item: Item, start_grid_pos: Vector2i):
	add_child(item)
	item.position = grid_to_pixel(start_grid_pos)
	item.clicked.connect(_on_item_clicked)
	
	for cell in item.cells:
		grid_data[start_grid_pos + cell] = item

func _on_item_clicked(item: Item):
	selected_item = item

func try_move_selected(direction: Vector2i) -> bool:
	if selected_item == null: return false

	var current_origin = Vector2i(selected_item.position) / tile_size
	
	for cell in selected_item.cells:
		var target_pos = current_origin + cell + direction
		
		if target_pos.x < 0 or target_pos.x >= grid_width or target_pos.y < 0 or target_pos.y >= grid_height:
			return false
		if grid_data.has(target_pos) and grid_data[target_pos] != selected_item:
			return false

	_perform_move(current_origin, direction)
	return true

func _perform_move(old_origin: Vector2i, direction: Vector2i):
	for cell in selected_item.cells:
		grid_data.erase(old_origin + cell)
		
	var new_origin = old_origin + direction
	selected_item.position = grid_to_pixel(new_origin)
	
	# Update target_position so dragging doesn't "snap" back after a successful move
	selected_item.target_position = selected_item.position
	
	for cell in selected_item.cells:
		grid_data[new_origin + cell] = selected_item

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			selected_item = null
			return

	if event is InputEventMouseMotion and selected_item != null:
		# Calculate smoothed target based on grab offset
		selected_item.update_target_position() # 
		
		# Calculate diff between where it IS and where it WANTS to be
		var diff = selected_item.target_position - selected_item.position # 
		
		if abs(diff.x) > tile_size:
			try_move_selected(Vector2i(sign(diff.x), 0))
		elif abs(diff.y) > tile_size:
			try_move_selected(Vector2i(0, sign(diff.y)))

func _draw():
	var w = grid_width * tile_size
	var h = grid_height * tile_size
	draw_rect(Rect2(0, 0, w, h), Color(0, 0, 0, 0.125))

	for x in range(grid_width + 1):
		draw_line(Vector2(x * tile_size, 0), Vector2(x * tile_size, h), Color.WHITE)
	for y in range(grid_height + 1):
		draw_line(Vector2(0, y * tile_size), Vector2(w, y * tile_size), Color.WHITE)
