extends Node

@export var main_menu_packed:PackedScene
@export var game_packed:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerData.load_player_data_json()
	load_main_menu("game_start")

func load_main_menu(origin:String)->void:
	if origin == "end_game":
		get_node("GameScene").queue_free()
		PlayerData.save_player_data_binary()
		PlayerData.save_player_data_json()
	var main_menu:Control = main_menu_packed.instantiate()
	main_menu.new_game_pressed.connect(new_game)
	main_menu.settings_pressed.connect(load_settings_menu)
	main_menu.exit_pressed.connect(exit_game)
	main_menu.about_pressed.connect(exit_game)
	add_child(main_menu)

func new_game(origin:String)->void:
	if origin == "main_menu":
		get_node("MainMenu").queue_free()
	if origin == "end_game":
		get_node("GameScene").queue_free()
		await get_tree().process_frame
	var game:Node2D = game_packed.instantiate()
	add_child(game)
	
func exit_game(origin:String)->void:
	get_tree().quit()

func load_settings_menu(origin:String)->void:
	pass
