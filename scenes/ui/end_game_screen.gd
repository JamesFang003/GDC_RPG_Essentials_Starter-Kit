extends Control

signal repeat(origin:String)
signal main_menu(origin:String)

var victorious:bool

func _ready() -> void:
	if victorious:
		%Result.set_text("Victorious")

func _on_main_menu_pressed() -> void:
	main_menu.emit("end_game")

func _on_replay_pressed() -> void:
	repeat.emit("end_game")
