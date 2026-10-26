extends Node

const KEY_LEVEL:String = "level"
const KEY_experience:String = "experience"

var save_path_json: String = "user://save_files/savefile.json"
var save_path_binary: String = "user://save_files/savefile.save"

var level:int = 1
var experience:int = 0

func create_data() -> Dictionary:
	return {
		KEY_LEVEL:level,
		KEY_experience:experience
	}
	
func save_player_data_json() -> void:
	var save_data = create_data()
	var err: Error = FileHandler.store_json_file(save_data,save_path_json,true)
	if err != OK:
		push_error("Could not save Player Data (JSON): ", str(err))	
	
func save_player_data_binary() -> void:
	var save_data = create_data()
	var err: Error = FileHandler.store_binary_file(save_data,save_path_binary,true)
	if err != OK:
		push_error("Could not save Player Data (Binary): ", str(err))	

func load_player_data_json() -> void:
	var save_data:Dictionary={}
	var err: Error = FileHandler.load_json_file(save_path_json,save_data)
	if err != OK:
		push_error("Could not load Player Data (JSON): ", str(err))
		return
	err = verify_player_data_json(save_data)
	if err != OK:
		push_error("Invalid Save Format")
		return
	
	level = save_data[KEY_LEVEL]
	experience = save_data[KEY_experience]

func load_player_data_binary() -> void:
	var save_data:Dictionary={}
	var err: Error = FileHandler.load_binary_file(save_path_binary,save_data)
	if err != OK:
		push_error("Could not load Player Data (Binary): ", str(err))
		return
	err = verify_player_data_json(save_data)
	if err != OK:
		push_error("Invalid Save Format")
		return
	
	level = save_data[KEY_LEVEL]
	experience = save_data[KEY_experience]
	
func verify_player_data_json(data:Dictionary) -> Error:
	if not data.has(KEY_LEVEL):
		return ERR_DOES_NOT_EXIST
	if not data.has(KEY_experience):
		return ERR_DOES_NOT_EXIST
	return OK

##same as json unless Vector2 involved
func verify_player_data_binary(data:Dictionary) -> Error:
	if not data.has(KEY_LEVEL):
		return ERR_DOES_NOT_EXIST
	if not data.has(KEY_experience):
		return ERR_DOES_NOT_EXIST
	return OK	
