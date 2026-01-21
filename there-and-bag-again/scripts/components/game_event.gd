class_name GameEvent
extends Node2D

@export var sprite: Sprite2D
@export var area: Area2D
@export var displacement:= 150.0
@export var spacer_scale = .2

var is_spacer: bool
var identifier: String # Asset_Info name
var texture: Texture2D

func _ready() -> void:
	sprite.texture = texture
	if is_spacer:
		sprite.scale *= spacer_scale
		area.scale *= spacer_scale

func move_self() -> void:
	var new_pos = Vector2(self.position.x - displacement, self.position.y)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, ^"position", new_pos, 0.5) # take two seconds to move

func _on_area_2d_area_entered(_area: Area2D) -> void:
	if not is_spacer:
		get_tree().call_group("Event Ocurred", "process_event", identifier)
		print(identifier + " processed")
	queue_free()
	
