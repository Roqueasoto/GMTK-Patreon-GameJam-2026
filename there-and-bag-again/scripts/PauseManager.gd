extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Create the input action via code if it's missing from Project Settings
	if not InputMap.has_action("pause"):
		InputMap.add_action("pause")
		var event = InputEventKey.new()
		event.physical_keycode = KEY_SPACE
		InputMap.action_add_event("pause", event)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		print("Pause toggled! New state: ", get_tree().paused)
