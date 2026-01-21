class_name EventData 
extends Resource

@export var id: String             # Unique Identifier - 1:1 with Item Id
@export var texture: Texture2D
@export var type: Utils.event_type
@export var damage: float           # Like Damage, Hunger, etc.
