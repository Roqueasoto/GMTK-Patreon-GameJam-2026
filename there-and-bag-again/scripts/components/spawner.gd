class_name Spawner
extends Node2D

const SPACER: Texture2D = preload("res://assets/items/silvercoin.png")
const EVENT_SCENE: = preload("uid://bek1vruybglwt")
const MAX_EVENTS: int = 5
@export var container: Node2D
@export var player: Character

var active_event_count = 0
var counter = 0
var should_move_events_back = false
var level_is_over = false

func _ready() -> void:
	EventManager.set_level(1)

func _on_timer_timeout() -> void:
	if active_event_count < MAX_EVENTS:
		_spawn_new_event()
	_move_events()
	
	print(level_is_over)
	print(active_event_count)
	if level_is_over and active_event_count == 0:
		print("game is won")
		get_tree().call_group("Game Manager", "load_game_won_screen")

func _move_events() -> void:
	if not should_move_events_back:
		get_tree().call_group("Game Events", "move_self_forward")
	else:
		get_tree().call_group("Game Events", "move_self_back")
		should_move_events_back = false

func _reset_events() -> void:
	should_move_events_back = true

func _remove_event(event: GameEvent) -> void:
	event.queue_free()
	active_event_count -= 1

func _spawn_new_event() -> void:
	var event: GameEvent = EVENT_SCENE.instantiate()
	event.connect("event_should_expire",_remove_event)
	event.connect("event_continues",_reset_events)
	event.player = player

	if counter == 0:
		var event_data: EventData = EventManager.get_next_event()
		event.identifier = event_data.id
		event.texture = event_data.texture
		event.type = event_data.type
		event.is_spacer = false
		event.hp = event_data.hp
		event.damage = event_data.damage
		# End level at the end of the line.
		level_is_over = event_data.type == Utils.event_type.NONE
		container.add_child(event)
		_update_counters()
	elif !level_is_over:
		event.identifier = ""
		event.texture = SPACER
		event.is_spacer = true
		event.type = Utils.event_type.NONE
		event.hp = 0
		event.damage = 0
		container.add_child(event)
		_update_counters()
	

func _update_counters() -> void:
	counter += 1
	counter = fmod(counter, 4)
	active_event_count += 1
