extends Node

@export var eventPath: String

func _ready() -> void:
	var event = FmodServer.create_event_instance(eventPath)
	event.start()
	print("fmod music playing")
	
	# register listener
	FmodServer.add_listener(0, self)
	print("Listener set.")
