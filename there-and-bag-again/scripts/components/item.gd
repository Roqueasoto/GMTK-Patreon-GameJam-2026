class_name Item
extends Node2D

@export var sprite: Sprite2D
@export var collider: CollisionShape2D
@export var layout: Array   # 2D Array of booleans, which determine item shape.
@export var properties: Array[Utils.property]


var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var shadow: Sprite2D

func _ready() -> void:

	# click and drag system
	_generate_shadow()
	$".".input_event.connect(drag_system)
	

	pass

func drag_system(_viewport, event, _shape_idx) -> void:
	print("test")
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = global_position - get_global_mouse_position()
			_animate_lift(true)

func _generate_shadow() -> void:
	shadow = $Sprite2D.duplicate()
	shadow.modulate = Color(0, 0, 0, 0.5) 
	shadow.position = Vector2(0, 0) 
	shadow.z_index = -1 
	add_child(shadow)
	
func _input(event: InputEvent) -> void:
	if dragging:
		if event is InputEventMouseButton and not event.pressed:
			dragging = false
			_animate_lift(false)
		elif event is InputEventMouseMotion:
			global_position = get_global_mouse_position() + drag_offset

func _animate_lift(lift_up: bool) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if lift_up:
		tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
		tween.parallel().tween_property(shadow, "position", Vector2(8, 8), 0.1) # Move shadow further away
	else:
		#tween.tween_property(self, "global_position", floor(global_position/100)*100, 0.1)
		tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
		tween.parallel().tween_property(shadow, "position", Vector2(2.0, 2.0), 0.1)
