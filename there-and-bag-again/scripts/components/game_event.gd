class_name GameEvent
extends Node2D

signal event_should_expire(event: GameEvent)
signal event_continues()

@export var sprite: Sprite2D
@export var area: Area2D
@export var displacement:= 150.0
@export var spacer_scale = .2
@export var health_bar: ProgressBar

var is_spacer: bool
var identifier: String # Asset_Info name
var type: Utils.event_type
var texture: Texture2D
var player: Character
var hp: float
var damage: float

func _ready() -> void:
	sprite.texture = texture
	if is_spacer:
		sprite.scale *= spacer_scale
		area.scale *= spacer_scale
	
	if type != Utils.event_type.ENEMY:
		health_bar.visible = false
	else:
		health_bar.max_value = hp
		health_bar.value = hp

func _move_self(distance: float) -> void:
	var new_pos = Vector2(self.position.x - distance, self.position.y)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, ^"position", new_pos, 0.5) # take half seconds

func move_self_forward() -> void:
	_move_self(displacement)

func move_self_back() -> void:
	_move_self(-displacement)

# Emits an event should expire signal to be handled by the spawner. 
func _on_area_2d_area_entered(_area: Area2D) -> void:
	match type:
		Utils.event_type.ENEMY:
			var player_damage = player.get_player_damage()
			hp -= player_damage
			health_bar.update(-player_damage)
			if hp <= 0:
				event_should_expire.emit(self)
			else:
				player.take_damage(damage)
				event_continues.emit()
		Utils.event_type.OBSTACLE:
			player.take_damage(damage)
			event_should_expire.emit(self)
		Utils.event_type.ITEM:
			get_tree().call_group("Event Ocurred", "process_event", identifier)
			print(identifier + " processed")
			event_should_expire.emit(self)
		Utils.event_type.NONE:
			event_should_expire.emit(self)
