@tool
extends EditorProperty

var grid_control = Control.new()
var current_value: Array[Vector2i] = []

func _init():
	# Set up the control that holds the drawing
	grid_control.custom_minimum_size = Vector2(0, 200) # Height of the editor
	grid_control.mouse_filter = Control.MOUSE_FILTER_STOP
	grid_control.connect("draw", _on_draw)
	grid_control.connect("gui_input", _on_gui_input)
	add_child(grid_control)
	set_bottom_editor(grid_control)

func _update_property():
	# Called when the Inspector refreshes
	var new_value = get_edited_object()[get_edited_property()]
	if new_value != null:
		current_value = new_value
	grid_control.queue_redraw()

func _on_draw():
	var obj = get_edited_object()
	if not obj or not "texture" in obj or not obj.texture:
		grid_control.draw_string(ThemeDB.get_fallback_font(), Vector2(10, 20), "Assign a Texture first!")
		return

	var tex = obj.texture
	var grid_dim = obj.grid_size
	
	# Calculate scaling to fit the control area
	var rect_size = grid_control.get_size()
	var aspect = tex.get_size().aspect()
	var draw_h = rect_size.y
	var draw_w = draw_h * aspect
	
	# Center the drawing
	var offset_x = (rect_size.x - draw_w) / 2
	var draw_rect = Rect2(offset_x, 0, draw_w, draw_h)
	
	# 1. Draw Texture
	grid_control.draw_texture_rect(tex, draw_rect, false)
	
	# 2. Draw Grid
	var cell_size = Vector2(draw_w / grid_dim.x, draw_h / grid_dim.y)
	
	for x in range(grid_dim.x):
		for y in range(grid_dim.y):
			var cell_rect = Rect2(Vector2(offset_x + x * cell_size.x, y * cell_size.y), cell_size)
			
			# Draw cell border
			grid_control.draw_rect(cell_rect, Color(1, 1, 1, 0.5), false, 1.0)
			
			# Draw fill if selected
			if Vector2i(x, y) in current_value:
				grid_control.draw_rect(cell_rect.grow(-2), Color(0, 1, 0, 0.4), true)

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var obj = get_edited_object()
		if not obj or not obj.texture: return

		# Calculate click position relative to grid
		var rect_size = grid_control.get_size()
		var aspect = obj.texture.get_size().aspect()
		var draw_w = rect_size.y * aspect
		var offset_x = (rect_size.x - draw_w) / 2
		
		var local_pos = event.position
		local_pos.x -= offset_x
		
		# Ignore clicks outside the texture area
		if local_pos.x < 0 or local_pos.x > draw_w: return
		
		var grid_dim = obj.grid_size
		var cell_size = Vector2(draw_w / grid_dim.x, rect_size.y / grid_dim.y)
		var cell_x = int(local_pos.x / cell_size.x)
		var cell_y = int(local_pos.y / cell_size.y)
		var clicked_cell = Vector2i(cell_x, cell_y)
		
		# Toggle logic
		var new_list = current_value.duplicate()
		if clicked_cell in new_list:
			new_list.erase(clicked_cell)
		else:
			new_list.append(clicked_cell)
		
		# Save and Update
		emit_changed(get_edited_property(), new_list)
		current_value = new_list
		grid_control.queue_redraw()
