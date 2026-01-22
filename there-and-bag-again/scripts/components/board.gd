class_name Board
extends Node2D

@export var tile_size := 100
@export var grid_width := 8
@export var grid_height := 8

# Drag 'item.tscn' here in the Inspector!
@export var item_scene: PackedScene 

@export var item_registry: Dictionary = {} 

var grid_data := {} 
var selected_item: Item = null

# Audio Setup
var audio_player := AudioStreamPlayer.new()

var sfx_pickup = preload("res://assets/sound/click1.mp3")
var sfx_putdown = preload("res://assets/sound/click2.mp3")

func _enter_tree() -> void:
	# This runs the moment the node enters the scene
	add_to_group("Event Ocurred") 

func _ready() -> void:
	# Setup Main Click Player
	audio_player.volume_db = -6.0 # Halve the volume (approx -6dB)
	add_child(audio_player)
	
	print("BOARD IS READY AND LISTENING! (Group: 'Event Ocurred')")
	
	# Fallback if Inspector assignment was missed
	if not item_scene:
		item_scene = load("res://scenes/components/items/item.tscn")

func process_event(identifier: String) -> void:
	# Normalize to lowercase to match registry keys (e.g. "Banana" -> "banana")
	var id_lower = identifier.to_lower()
	print("Board: Event received for '%s' (normalized: '%s')" % [identifier, id_lower])
	
	if not item_registry.has(id_lower):
		push_warning("Board: Unknown ID '%s'. Valid keys: %s" % [id_lower, item_registry.keys()])
		return

	# Use instantiate() instead of new() to ensure the scene is built correctly
	var item = item_scene.instantiate() as Item
	if not item:
		push_error("Board: Failed to instantiate Item!")
		return
		
	item.data = item_registry[id_lower]
	
	if not _try_auto_place(item):
		item.queue_free()
		print("Board: Inventory full, discarded '%s'" % identifier)
	else:
		print("Board: Successfully placed '%s'" % identifier)

func _try_auto_place(item: Item) -> bool:
	for y in range(grid_height):
		for x in range(grid_width):
			var pos := Vector2i(x, y)
			if _can_place_at(item, pos):
				place_item(item, pos)
				return true
	return false

func _can_place_at(item: Item, origin: Vector2i) -> bool:
	for cell in item.cells:
		var target := origin + cell
		if not _is_cell_valid(target): return false
		if grid_data.has(target): return false
	return true

func place_item(item: Item, grid_pos: Vector2i) -> void:
	if item.get_parent() != self:
		add_child(item)
	item.position = Vector2(grid_pos) * tile_size
	
	for cell in item.cells:
		grid_data[grid_pos + cell] = item

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				print("DEBUG: Mouse Down detected at %d ms" % Time.get_ticks_msec())
				_attempt_grab(get_local_mouse_position())
			elif selected_item:
				print("DEBUG: Mouse Up (Drop) detected at %d ms" % Time.get_ticks_msec())
				# Play drop sound
				audio_player.stream = sfx_putdown
				audio_player.pitch_scale = randf_range(0.95, 1.05)
				
				print("DEBUG: Triggering Putdown Audio at %d ms" % Time.get_ticks_msec())
				audio_player.play()
				
				selected_item = null
	elif event is InputEventMouseMotion and selected_item:
		_handle_drag(get_local_mouse_position())

func _attempt_grab(local_mouse: Vector2) -> void:
	var cell := Vector2i(local_mouse / tile_size)
	if grid_data.has(cell):
		selected_item = grid_data[cell]
		selected_item.grab_offset = selected_item.position - local_mouse
		
		# Play pickup sound
		audio_player.stream = sfx_pickup
		audio_player.pitch_scale = randf_range(0.95, 1.05)
		
		print("DEBUG: Triggering Pickup Audio at %d ms" % Time.get_ticks_msec())
		audio_player.play()
		
		get_viewport().set_input_as_handled()

func _handle_drag(local_mouse: Vector2) -> void:
	var raw_pos := local_mouse + selected_item.grab_offset
	var target_grid_pos := Vector2i((raw_pos / tile_size).round())
	var current_grid_pos := Vector2i(selected_item.position / tile_size)
	var diff := target_grid_pos - current_grid_pos
	
	if diff.x != 0: _try_move_item(Vector2i(sign(diff.x), 0))
	current_grid_pos = Vector2i(selected_item.position / tile_size)
	diff = target_grid_pos - current_grid_pos
	if diff.y != 0: _try_move_item(Vector2i(0, sign(diff.y)))

func _try_move_item(direction: Vector2i) -> bool:
	var current_origin := Vector2i(selected_item.position / tile_size)
	for cell in selected_item.cells:
		var target := current_origin + cell + direction
		if not _is_cell_valid(target) or (grid_data.get(target) and grid_data[target] != selected_item):
			return false
	
	for cell in selected_item.cells: grid_data.erase(current_origin + cell)
	var new_origin := current_origin + direction
	selected_item.position = Vector2(new_origin) * tile_size
	for cell in selected_item.cells: grid_data[new_origin + cell] = selected_item
	return true

func _is_cell_valid(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_width and pos.y >= 0 and pos.y < grid_height

func _draw() -> void:
	var w := grid_width * tile_size
	var h := grid_height * tile_size
	draw_rect(Rect2(0, 0, w, h), Color(0, 0, 0, 0.125))
	for x in range(grid_width + 1):
		draw_line(Vector2(x * tile_size, 0), Vector2(x * tile_size, h), Color.WHITE)
	for y in range(grid_height + 1):
		draw_line(Vector2(0, y * tile_size), Vector2(w, y * tile_size), Color.WHITE)
