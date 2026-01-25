extends Button

func _on_pressed() -> void:
	get_tree().call_group("Game Manager", "load_main_game")
