class_name GameManager extends Node

const SPLASH_SCENE = preload("res://scenes/levels/splash_screen.tscn")
const TUTORIAL_SCENE = preload("res://scenes/levels/tutorial_screen.tscn")
const MAIN_GAME_SCENE = preload("uid://dx2klpgdf7ied")
const WIN_GAME_SCENE = preload("res://scenes/levels/win_game.tscn")
const GAME_OVER_SCENE = preload("res://scenes/levels/game_over.tscn")

@export var music_player: FmodEventEmitter2D

var current_scene: Node
var master_string_bank: FmodBank
var master_bank: FmodBank
var music_bank: FmodBank
var sfx_bank: FmodBank

func _enter_tree():
	# load banks
	master_string_bank = FmodServer.load_bank("res://assets/music/ThereAndBagAgainFmod/Build/Banks/Master.strings.bank", FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
	master_bank = FmodServer.load_bank("res://assets/music/ThereAndBagAgainFmod/Build/Banks/Master.bank", FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
	music_bank = FmodServer.load_bank("res://assets/music/ThereAndBagAgainFmod/Build/Banks/Music.bank", FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
	sfx_bank = FmodServer.load_bank("res://assets/music/ThereAndBagAgainFmod/Build/Banks/SFX.bank", FmodServer.FMOD_STUDIO_LOAD_BANK_NORMAL)
	print("Fmod initialised.")

# Assuming 1st child under Game contains the scenes
func _ready() -> void:
	current_scene = get_child(0)

func load_splash_screen() -> void:
	var scene = SPLASH_SCENE.instantiate()
	_load_new_scene(scene)

func load_tutorial() -> void:
	update_music(Utils.music_type.START)
	var scene = TUTORIAL_SCENE.instantiate()
	_load_new_scene(scene)

func load_main_game() -> void:
	update_music(Utils.music_type.MAIN)
	var scene = MAIN_GAME_SCENE.instantiate()
	_load_new_scene(scene)

func load_game_over() -> void:
	update_music(Utils.music_type.BAD_END)
	var scene = GAME_OVER_SCENE.instantiate()
	scene.score = calculate_score()
	_load_new_scene(scene)

func load_game_won_screen() -> void:
	update_music(Utils.music_type.GOOD_END)
	var scene = WIN_GAME_SCENE.instantiate()
	scene.score = calculate_score()
	_load_new_scene(scene)

func _load_new_scene(new_scene: Node) -> void:
	add_child(new_scene)
	current_scene.queue_free()
	current_scene = new_scene

func quit_game() -> void:
	get_tree().quit()

func calculate_score() -> float:
	var board = current_scene.get_node("CanvasLayer/Bag/Board")
	var health_bar = current_scene.get_node("AdventureView/Character/HealthBar")
	var score = 0
	if board:
		var totals = board.get_total_of_all_item_properties()
		score = totals.score
	if health_bar:
		score += health_bar.value
	return score

func update_music(desired_music: Utils.music_type) -> void:
	match desired_music:
		Utils.music_type.START:
			if music_player.event_guid != "{588cba52-0e4f-4ad9-b3f4-863238148978}":
				music_player.event_name = "event:/StartScreenMusic"
				music_player.play()
		Utils.music_type.MAIN:
			music_player.event_name = "event:/MainGameMusic"
			music_player.play()
		Utils.music_type.BAD_END:
			music_player.event_name = "event:/GameOverMusic"
			music_player.play()
		Utils.music_type.GOOD_END:
			music_player.event_name = "event:/WinGameMusic"
			music_player.play()
