extends Control

var score: int = 0

@onready var score_label = $ScoreLabel

func _ready():
	score_label.text = "Score: " + str(score)
