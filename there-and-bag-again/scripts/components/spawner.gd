class_name Spawner
extends Node2D

const SPACER: Texture2D = preload("res://assets/items/silvercoin.png")
const EVENT_SCENE: = preload("uid://bek1vruybglwt")
@export var container: Node2D

var event_counter = 0

func _ready() -> void:
	EventManager.set_level(1)

func _on_timer_timeout() -> void:
	_spawn_new_event()
	_move_events()
	_update_event_counter()

func _move_events() -> void:
	get_tree().call_group("Game Events", "move_self")

func _spawn_new_event() -> void:
	var event: GameEvent = EVENT_SCENE.instantiate()
	
	if event_counter == 0:
		var event_data: EventData = EventManager.get_next_event()
		event.identifier = event_data.id
		event.texture = event_data.texture
		event.is_spacer = false
	else:
		event.identifier = ""
		event.texture = SPACER
		event.is_spacer = true
	
	container.add_child(event)

func _update_event_counter() -> void:
	event_counter += 1
	event_counter = fmod(event_counter, 4)
