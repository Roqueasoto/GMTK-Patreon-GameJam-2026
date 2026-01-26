class_name ItemTooltip
extends PanelContainer

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var stats_label: Label = $VBoxContainer/StatsLabel

func _ready() -> void:
	# Ensure the tooltip updates and moves even when the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func update_data(item_data: ItemData):
	name_label.text = item_data.display_name
	
	var stats_text = ""
	if item_data.healing > 0:
		stats_text += "Healing: %s\n" % item_data.healing
	if item_data.stamina > 0:
		stats_text += "Stamina: %s\n" % item_data.stamina
	if item_data.damage_increase > 0:
		stats_text += "Damage: %s\n" % item_data.damage_increase
	if item_data.defence > 0:
		stats_text += "Defence: %s\n" % item_data.defence
	if item_data.weight > 0:
		stats_text += "Weight: %s\n" % item_data.weight
	if item_data.score > 0:
		stats_text += "Score: %s\n" % item_data.score
	if item_data.lifetime > 0:
		stats_text += "Lifetime: %s\n" % item_data.lifetime
	
	stats_label.text = stats_text
	
func _physics_process(_delta):
	global_position = get_global_mouse_position() + Vector2(10, 10)
