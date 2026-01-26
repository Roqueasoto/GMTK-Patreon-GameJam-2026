class_name Character
extends Node2D

@export var sfx: FmodEventEmitter2D
@export var player_displacement = 6.0
@export var stamina_drain = -1     # Negative implies stamina drain per tick
@export var player_damage = 5      # barehanded, modified by items
@export var weight_modifier = 0.1 # Weight modifier to make weight less punishing

@onready var board = get_tree().get_first_node_in_group("Board")

func _process(_delta) -> void:
	_move_player()

func _move_player() -> void:
	position.x += player_displacement

func update_health(delta: float) -> void:
	print("delta %s" % -delta)
	get_tree().call_group("Health", "update", delta)

func update_stamina(delta: float) -> void:
	get_tree().call_group("Stamina", "update", delta)

func _on_timer_timeout() -> void:
	var active_totals = {"stamina": 0.0}
	var all_totals = {"weight": 0.0}
	if board:
		active_totals = board.get_total_of_active_item_properties()
		all_totals = board.get_total_of_all_item_properties()
	var weight_penalty = all_totals.weight * weight_modifier
	update_stamina(stamina_drain - weight_penalty + active_totals.stamina)

# This function is called when stamina damage is taken and it would reduce
# remaining stamina below 0. Take an equal amount of Health Damage.
func _on_stamina_bar_bar_is_empty(delta: float) -> void:
	print("empty_bar")
	update_health(delta*2)

func _on_health_bar_bar_is_empty(_delta: float) -> void:
	print("Game Over")
	get_tree().call_group("Game Manager", "load_game_over")

func take_damage(amount: float):
	var totals = {"defence": 0.0}
	if board:
		totals = board.get_total_of_active_item_properties()
	var actual_damage = amount - totals.defence
	if actual_damage < 0:
		actual_damage = 0
	else: # make some noise
		sfx.play_one_shot()
	update_health(-actual_damage)

func get_player_damage() -> float:
	var totals = {"damage_increase": 0.0}
	if board:
		totals = board.get_total_of_active_item_properties()
	return player_damage + totals.damage_increase
