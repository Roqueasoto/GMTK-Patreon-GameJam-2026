class_name GameManager extends Node

const SPLASH_SCENE = preload("res://scenes/levels/splash_screen.tscn")
const TUTORIAL_SCENE = preload("res://scenes/levels/tutorial_screen.tscn")
const MAIN_GAME_SCENE = preload("uid://dx2klpgdf7ied")
const WIN_GAME_SCENE = preload("res://scenes/levels/win_game.tscn")
const GAME_OVER_SCENE = preload("res://scenes/levels/game_over.tscn")

var current_scene: Node

# Assuming only 1 child under Game
func _ready() -> void:
	current_scene = get_child(0)

func load_splash_screen() -> void:
	print("load")
	var scene = SPLASH_SCENE.instantiate()
	_load_new_scene(scene)

func load_tutorial() -> void:
	var scene = TUTORIAL_SCENE.instantiate()
	_load_new_scene(scene)

func load_main_game() -> void:
	var scene = MAIN_GAME_SCENE.instantiate()
	_load_new_scene(scene)

func load_game_over() -> void:
	var scene = GAME_OVER_SCENE.instantiate()
	_load_new_scene(scene)

func load_game_won_screen() -> void:
	var scene = WIN_GAME_SCENE.instantiate()
	_load_new_scene(scene)

func _load_new_scene(new_scene: Node) -> void:
	print("new scene added")
	add_child(new_scene)
	current_scene.queue_free()
	current_scene = new_scene

func quit_game() -> void:
	get_tree().quit()
