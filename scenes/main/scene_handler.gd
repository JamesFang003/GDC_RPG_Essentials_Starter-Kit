extends Node

@export var main_menu_packed:PackedScene
@export var game_packed:PackedScene

var current_game: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_main_menu("game_start")

func load_main_menu(origin:String)->void:
	if origin == "end_game":
		PlayerData.save_player_data_binary()
		PlayerData.save_player_data_json()
		if is_instance_valid(current_game):
			current_game.queue_free()
	var main_menu:Control = main_menu_packed.instantiate()
	main_menu.new_game_pressed.connect(new_game)
	main_menu.settings_pressed.connect(load_settings_menu)
	main_menu.exit_pressed.connect(exit_game)
	main_menu.load_pressed.connect(load_game)
	add_child(main_menu)

func new_game(origin:String)->void:
	if origin == "main_menu":
		get_node("MainMenu").queue_free()
	if origin == "end_game":
		if is_instance_valid(current_game):
			current_game.queue_free()
			await get_tree().process_frame
	current_game = game_packed.instantiate()
	add_child(current_game)
	
func exit_game(_origin:String)->void:
	get_tree().quit()
	
func load_game(_origin:String)->void:
	PlayerData.load_player_data_json()
	new_game("main_menu")

func replay_game(_origin:String)->void:
	PlayerData.load_player_data_json()
	new_game("end_game")

func load_settings_menu(_origin:String)->void:
	get_tree().quit()
