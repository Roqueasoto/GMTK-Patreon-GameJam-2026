class_name Board
extends Node2D

@export var thud_sfx: FmodEventEmitter2D
@export var slide_sfx: FmodEventEmitter2D

# Constants and Configuration
var tile_size := Utils.TILE_SIZE
var grid_width := Utils.GRID_RESOLUTION
var grid_height := Utils.GRID_RESOLUTION

var spawn_height := 5
var spawn_width := 5
var spawn_x_offset := (grid_width - spawn_width) / 2

# State Management
var item_scene: PackedScene 
var item_registry: Dictionary = {} 
var grid_data := {} 
var selected_item: Item = null
var active_items: Array = []

func get_total_of_active_item_properties() -> Dictionary:
	var totals = {
		"healing": 0.0,
		"stamina": 0.0,
		"damage_increase": 0.0,
		"defence": 0.0,
		"score": 0.0,
		"weight": 0.0,
	}
	for item in active_items:
		if item.data:
			totals["healing"] += item.data.healing
			totals["stamina"] += item.data.stamina
			totals["damage_increase"] += item.data.damage_increase
			totals["defence"] += item.data.defence
			totals["score"] += item.data.score
			totals["weight"] += item.data.weight
	return totals

func get_all_items() -> Array:
	var items = []
	for child in get_children():
		if child is Item:
			items.append(child)
	return items

func get_total_of_all_item_properties() -> Dictionary:
	var totals = {
		"healing": 0.0,
		"stamina": 0.0,
		"damage_increase": 0.0,
		"defence": 0.0,
		"score": 0.0,
		"weight": 0.0,
	}
	var all_items = get_all_items()
	for item in all_items:
		if item.data:
			totals["healing"] += item.data.healing
			totals["stamina"] += item.data.stamina
			totals["damage_increase"] += item.data.damage_increase
			totals["defence"] += item.data.defence
			totals["score"] += item.data.score
			totals["weight"] += item.data.weight
	return totals

func _enter_tree() -> void:
	add_to_group("Event Ocurred") 

func _ready() -> void:
	item_scene = load("res://scenes/components/items/item.tscn")

# Public Event Handling
func process_event(identifier: String) -> void:
	var id_lower = identifier.to_lower()
	if not item_registry.has(id_lower): return

	var item = item_scene.instantiate() as Item
	item.data = item_registry[id_lower]
	item.used.connect(_on_item_used)
	item.unused.connect(_on_item_unused)
	
	if _try_spawn_in_area(item) or _try_auto_place(item):
		queue_redraw()
	else:
		item.queue_free()

# Item Lifecycle Callbacks
func _on_item_used(item: Item) -> void:
	print("Board: Item '%s' triggered via spawn area drop!" % item.data.id)
	item.is_in_use = true
	if not active_items.has(item):
		active_items.append(item)

func _on_item_unused(item: Item) -> void:
	print("Board: Item '%s' is no longer in use (picked up)!" % item.data.id)
	item.is_in_use = false
	if active_items.has(item):
		active_items.erase(item)

# Placement Logic
func _try_spawn_in_area(item: Item) -> bool:
	for y in range(-spawn_height, 0):
		for x in range(spawn_x_offset, spawn_x_offset + spawn_width):
			if _attempt_placement(item, Vector2i(x, y)): 
				
				return true
	return false

func _try_auto_place(item: Item) -> bool:
	for y in range(grid_height):
		for x in range(grid_width):
			if _attempt_placement(item, Vector2i(x, y)): return true
	return false

func _attempt_placement(item: Item, pos: Vector2i) -> bool:
	if _can_place_at(item, pos):
		place_item(item, pos)
		return true
	return false

func _can_place_at(item: Item, origin: Vector2i) -> bool:
	for cell in item.cells:
		var target = origin + cell
		if not _is_cell_valid(target) or grid_data.has(target): return false
	return true

func place_item(item: Item, grid_pos: Vector2i) -> void:
	if item.get_parent() != self:
		thud_sfx.play_one_shot()
		add_child(item)
	
	item.position = Vector2(grid_pos) * tile_size
	for cell in item.cells:
		grid_data[grid_pos + cell] = item

func remove_item(item: Item) -> void:
	if active_items.has(item):
		active_items.erase(item)
	var origin = Vector2i(item.position / tile_size)
	for cell in item.cells:
		if grid_data.has(origin + cell) and grid_data[origin + cell] == item:
			grid_data.erase(origin + cell)
	item.queue_free()

func process_item_lifetimes() -> void:
	var items_to_remove = []
	for child in get_children():
		if child is Item:
			if child.is_in_use:
				child.current_lifetime -= 1
				if child.current_lifetime <= 0:
					items_to_remove.append(child)
	
	for item in items_to_remove:
		remove_item(item)

# Input Handling
func _input(event: InputEvent) -> void:
	var local_mouse = get_local_mouse_position()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_attempt_grab(local_mouse)
		elif selected_item:
			_check_drop_zone()
			slide_sfx.play_one_shot()
			selected_item = null
	
	elif event is InputEventMouseMotion and selected_item:
		_handle_drag(local_mouse)

func _attempt_grab(local_mouse: Vector2) -> void:
	var cell = Vector2i((local_mouse / tile_size).floor())
	if not grid_data.has(cell): return

	selected_item = grid_data[cell]
	selected_item.grab_offset = selected_item.position - local_mouse
	
	if selected_item.is_in_use and _is_in_spawn_zone(cell):
		selected_item.unused.emit(selected_item)
		
	slide_sfx.play_one_shot()
	get_viewport().set_input_as_handled()

func _handle_drag(local_mouse: Vector2) -> void:
	var target_grid_pos = Vector2i(((local_mouse + selected_item.grab_offset) / tile_size).round())
	var current_grid_pos = Vector2i(selected_item.position / tile_size)
	var diff = target_grid_pos - current_grid_pos
	
	if diff.x != 0: _try_move_item(Vector2i(sign(diff.x), 0))
	current_grid_pos = Vector2i(selected_item.position / tile_size)
	diff = target_grid_pos - current_grid_pos
	if diff.y != 0: _try_move_item(Vector2i(0, sign(diff.y)))

func _try_move_item(direction: Vector2i) -> bool:
	var origin = Vector2i(selected_item.position / tile_size)
	for cell in selected_item.cells:
		var target = origin + cell + direction
		if not _is_cell_valid(target): return false
		if grid_data.has(target) and grid_data[target] != selected_item: return false
	
	for cell in selected_item.cells: grid_data.erase(origin + cell)
	var new_origin = origin + direction
	selected_item.position = Vector2(new_origin) * tile_size
	for cell in selected_item.cells: grid_data[new_origin + cell] = selected_item
	return true

func _check_drop_zone() -> void:
	var origin = Vector2i(selected_item.position / tile_size)
	for cell in selected_item.cells:
		if not _is_in_spawn_zone(origin + cell): return
	selected_item.used.emit(selected_item)

# Helpers
func _is_cell_valid(pos: Vector2i) -> bool:
	var in_board = pos.x >= 0 and pos.x < grid_width and pos.y >= 0 and pos.y < grid_height
	return in_board or _is_in_spawn_zone(pos)

func _is_in_spawn_zone(pos: Vector2i) -> bool:
	return pos.x >= spawn_x_offset and pos.x < (spawn_x_offset + spawn_width) \
		and pos.y >= -spawn_height and pos.y < 0

func _draw() -> void:
	var line_color := Color(0.75, 0.6, 0.4, 0.5)
	var bw = grid_width * tile_size
	var bh = grid_height * tile_size
	
	# Board
	draw_rect(Rect2(0, 0, bw, bh), Color(0, 0, 0, 0.125))
	for x in range(grid_width + 1): draw_line(Vector2(x * tile_size, 0), Vector2(x * tile_size, bh), line_color)
	for y in range(grid_height + 1): draw_line(Vector2(0, y * tile_size), Vector2(bw, y * tile_size), line_color)

	# Spawn Zone
	var sw = spawn_width * tile_size
	var sh = spawn_height * tile_size
	var sx = spawn_x_offset * tile_size
	draw_rect(Rect2(sx, -sh, sw, sh), Color(0.2, 0.5, 0.8, 0.15))
	for x in range(spawn_width + 1): draw_line(Vector2(sx + x * tile_size, -sh), Vector2(sx + x * tile_size, 0), line_color)
	for y in range(spawn_height + 1): draw_line(Vector2(sx, -sh + y * tile_size), Vector2(sx + sw, -sh + y * tile_size), line_color)
