extends Node2D

signal levelup()

var total_enemies:int
var killed_enemies:int = 0
var game_end:bool = false

@export var end_game_packed:PackedScene

@onready var HUD: Control = $UI/HUD

func _ready() -> void:
	var enemy_array = get_tree().get_nodes_in_group("enemy")
	total_enemies=enemy_array.size()
	print(total_enemies)
	for i in enemy_array:
		i.died.connect(enemy_died)
		
	var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
	levelup.connect(player.calculate_stats)
	player.game_over.connect(display_end_game_screen)
	player.update_hp.connect(HUD.update_hp_bar)
	
func enemy_died(exp_gain:int) -> void:
	killed_enemies+=1
	print(killed_enemies)
	experience_gained(exp_gain)
	if killed_enemies >= total_enemies:
		display_end_game_screen(true)

func experience_gained(exp_gain: int) -> void:
	if PlayerData.level == GameData.MAX_LEVEL:
		return
	var new_experience = PlayerData.experience + exp_gain
	if new_experience >= GameData.LEVEL_THRESHOLDS[PlayerData.level-1]:
		level_up(new_experience)
	else:
		PlayerData.experience = new_experience

func display_end_game_screen(victorious:bool) -> void:
	#if game_end:
	#	return
	var end_menu:Control = end_game_packed.instantiate()
	end_menu.victorious = victorious
	
	var scene_handler = get_node("/root/SceneHandler")
	end_menu.repeat.connect(scene_handler.replay_game)
	end_menu.main_menu.connect(scene_handler.load_main_menu)
	$UI.add_child(end_menu)
	#game_end = true
	
	await get_tree().create_timer(0.4).timeout
	var enemy_array = get_tree().get_nodes_in_group("enemy")
	for i in enemy_array:
		i.set_process_mode(Node.PROCESS_MODE_DISABLED)
	
func level_up(new_experience) -> void:
	print("Level up")
	new_experience-=GameData.LEVEL_THRESHOLDS[PlayerData.level-1]
	PlayerData.level+=1
	PlayerData.experience=new_experience
	levelup.emit()
	HUD.update_level()
