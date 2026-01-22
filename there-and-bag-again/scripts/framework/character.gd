extends Node2D

@export var player_displacement = 6.0
@export var stamina_drain = -5  # Negative implies stamina drain per tick

func _process(_delta) -> void:
	_move_player()

func _move_player() -> void:
	position.x += player_displacement

func update_health(delta: float) -> void:
	get_tree().call_group("Health", "update", delta)

func update_stamina(delta: float) -> void:
	get_tree().call_group("Stamina", "update", delta)

func _on_timer_timeout() -> void:
	update_stamina(stamina_drain)

# This function is called when stamina damage is taken and it would reduce
# remaining stamina below 0. Take an equal amount of Health Damage.
func _on_stamina_bar_bar_is_empty(delta: float) -> void:
	update_health(delta)

func _on_health_bar_bar_is_empty(_delta: float) -> void:
	print("Game Over")
