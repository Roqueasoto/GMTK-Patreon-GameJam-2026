extends Node

@export var all_levels: ResourceGroup = preload("res://resources/groups/all_levels.tres")

var level_assets: Dictionary[int,LevelData]
var current_level: LevelData
var index: int = 0

func _ready() -> void:
	for level: LevelData in all_levels.load_all():
		level_assets[level.id] = level

func get_level_assets() -> Dictionary[int,LevelData]:
	return level_assets

# get level by id (unique string)
func get_level(id: int) -> LevelData:
	return level_assets[id]

# Sets the level for use with get_next_event method. Also sets the index to 0.
# If id is invalid, or nonexisted, will set the current level to null.
func set_level(id: int) -> void:
	current_level = level_assets[id]
	index = 0

# Gets the next event in the level's event data. If reached the end, or no level
# is currently set, returns an event with the none-type (no other guarantees).
func get_next_event() -> EventData:
	if current_level and index < current_level.event_list.size():
		var event = current_level.event_list.get(index)
		index += 1
		return event
	else:
		var empty_event = EventData.new()
		empty_event.type = Utils.event_type.NONE
		return empty_event
