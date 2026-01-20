class_name Spawner
extends Node2D

const SPACER: Texture2D = preload("res://assets/items/silvercoin.png")
const BANANA: ItemData = preload("res://scenes/components/items/item_data/banana.tres")
const EVENT_SCENE: = preload("uid://bek1vruybglwt")
@export var container: Node2D

var event_counter = 0

func _on_timer_timeout() -> void:
	_spawn_new_event()
	_move_events()
	_update_event_counter()

func _move_events() -> void:
	get_tree().call_group("Game Events", "move_self")

func _spawn_new_event() -> void:
	var event = EVENT_SCENE.instantiate()
	event.identifier = BANANA.display_name
	event.texture = BANANA.texture if event_counter == 0 else SPACER
	event.is_spacer = event_counter != 0
	container.add_child(event)

func _update_event_counter() -> void:
	event_counter += 1
	event_counter = fmod(event_counter, 4)
