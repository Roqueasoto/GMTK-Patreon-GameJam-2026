extends Node2D

@onready var board = get_tree().get_first_node_in_group("Board")
@onready var timer = $Character/Spawner/Timer
@onready var character = $Character

func _ready():
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	if board:
		var totals = board.get_total_of_active_item_properties()
		if character and totals.healing > 0 :
			character.update_health(totals.healing)
