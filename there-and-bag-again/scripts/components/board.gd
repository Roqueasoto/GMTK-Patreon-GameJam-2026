class_name Board

extends Node2D


var tile_size := Utils.TILE_SIZE

var grid_width := Utils.GRID_RESOLUTION

var grid_height := Utils.GRID_RESOLUTION


var spawn_height := 5

var spawn_width := 5

var spawn_x_offset := (grid_width - spawn_width) / 2


var item_scene: PackedScene 

var item_registry: Dictionary = {} 

var grid_data := {} 

var selected_item: Item = null


var audio_player := AudioStreamPlayer.new()

var sfx_pickup = preload("res://assets/sound/click1.mp3")

var sfx_putdown = preload("res://assets/sound/click2.mp3")


func _enter_tree() -> void:

	add_to_group("Event Ocurred") 


func _ready() -> void:

	audio_player.volume_db = -6.0

	add_child(audio_player)

	item_scene = load("res://scenes/components/items/item.tscn")


func process_event(identifier: String) -> void:

	var id_lower = identifier.to_lower()

	if not item_registry.has(id_lower): return


	var item = item_scene.instantiate() as Item

	item.data = item_registry[id_lower]

	item.used.connect(_on_item_used)

	item.unused.connect(_on_item_unused) # Connected unused signal

	

	if not _try_spawn_in_area(item) and not _try_auto_place(item):

		item.queue_free()

	else:

		queue_redraw()


func _on_item_used(item: Item) -> void:

	print("Board: Item '%s' triggered via spawn area drop!" % item.data.id)

	item.is_in_use = true # Mark as used


func _on_item_unused(item: Item) -> void:

	print("Board: Item '%s' is no longer in use (picked up)!" % item.data.id)

	item.is_in_use = false # Mark as no longer used

func _try_spawn_in_area(item: Item) -> bool:

	for y in range(-spawn_height, 0):

		for x in range(spawn_x_offset, spawn_x_offset + spawn_width):

			var pos := Vector2i(x, y)

			if _can_place_at(item, pos):

				place_item(item, pos)

				return true

	return false


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

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:

		if event.pressed:

			_attempt_grab(get_local_mouse_position())

		elif selected_item:

			_check_drop_zone()

			audio_player.stream = sfx_putdown

			audio_player.play()

			selected_item = null

	elif event is InputEventMouseMotion and selected_item:

		_handle_drag(get_local_mouse_position())


func _check_drop_zone() -> void:

	var current_origin := Vector2i(selected_item.position / tile_size)

	var all_cells_in_spawn := true

	

	for cell in selected_item.cells:

		var target := current_origin + cell

		var in_spawn = target.x >= spawn_x_offset and target.x < (spawn_x_offset + spawn_width) \

					   and target.y >= -spawn_height and target.y < 0

		

		if not in_spawn:

			all_cells_in_spawn = false

			break

			

	if all_cells_in_spawn:

		selected_item.used.emit(selected_item)


func _attempt_grab(local_mouse: Vector2) -> void:

	var cell := Vector2i((local_mouse / tile_size).floor())

	if grid_data.has(cell):

		selected_item = grid_data[cell]

		selected_item.grab_offset = selected_item.position - local_mouse

		

		# Logic check: Only trigger unused if picked up FROM the spawn area AND it was in_use

		var in_spawn = cell.x >= spawn_x_offset and cell.x < (spawn_x_offset + spawn_width) \

					   and cell.y >= -spawn_height and cell.y < 0

		

		if selected_item.is_in_use and in_spawn:

			selected_item.unused.emit(selected_item)

			

		audio_player.stream = sfx_pickup

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

	var in_board = pos.x >= 0 and pos.x < grid_width and pos.y >= 0 and pos.y < grid_height

	var in_spawn = pos.x >= spawn_x_offset and pos.x < (spawn_x_offset + spawn_width) \

				   and pos.y >= -spawn_height and pos.y < 0

	return in_board or in_spawn


func _draw() -> void:

	var line_color := Color(0.75, 0.6, 0.4, 0.5)

	var bw := grid_width * tile_size

	var bh := grid_height * tile_size

	draw_rect(Rect2(0, 0, bw, bh), Color(0, 0, 0, 0.125))

	for x in range(grid_width + 1):

		draw_line(Vector2(x * tile_size, 0), Vector2(x * tile_size, bh), line_color)

	for y in range(grid_height + 1):

		draw_line(Vector2(0, y * tile_size), Vector2(bw, y * tile_size), line_color)


	var sw := spawn_width * tile_size

	var sh := spawn_height * tile_size

	var sx := spawn_x_offset * tile_size

	var sy := -sh

	draw_rect(Rect2(sx, sy, sw, sh), Color(0.2, 0.5, 0.8, 0.15))

	for x in range(spawn_width + 1):

		draw_line(Vector2(sx + x * tile_size, sy), Vector2(sx + x * tile_size, 0), line_color)

	for y in range(spawn_height + 1):

		draw_line(Vector2(sx, sy + y * tile_size), Vector2(sx + sw, sy + y * tile_size), line_color)
