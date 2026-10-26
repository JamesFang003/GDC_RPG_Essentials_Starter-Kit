extends Node

func store_json_file(data:Dictionary, file_path:String,create_dir:bool)-> Error:
	var result:Array = _open_file_for_write(file_path,create_dir)
	var err:Error = result[0] as Error
	var file: FileAccess = result[1] as FileAccess
	
	if err != OK:
		return err
	
	file.store_string(JSON.stringify(data))
	file.close()
	return OK
	
func store_binary_file(data:Dictionary, file_path:String,create_dir:bool)-> Error:
	var result:Array = _open_file_for_write(file_path,create_dir)
	var err:Error = result[0] as Error
	var file: FileAccess = result[1] as FileAccess
	
	if err != OK:
		return err
	
	file.store_var(data, false)
	file.close()
	return OK
	
func load_json_file(file_path:String, data:Dictionary) -> Error:
	data.clear()
	var result:Array = _open_file_for_read(file_path)
	var err:Error = result[0] as Error
	var file: FileAccess = result[1] as FileAccess
	
	if err != OK:
		return err
		
	var json_string:String = file.get_as_text()
	file.close()
	
	var json:JSON = JSON.new()
	err = json.parse(json_string)
	if err != OK:
		return err
		
	var json_data:Variant = json.get_data()
	if typeof(json_data) != TYPE_DICTIONARY:
		return ERR_INVALID_DATA
	
	data.merge(json_data as Dictionary,true)
	return OK
	
func load_binary_file(file_path:String, data:Dictionary)-> Error:
	data.clear()
	var result:Array = _open_file_for_read(file_path)
	var err:Error = result[0] as Error
	var file: FileAccess = result[1] as FileAccess
	
	if err != OK:
		return err
		
	var binary_data:Variant = file.get_var(false)
	file.close()
	if typeof(binary_data) != TYPE_DICTIONARY:
		return ERR_INVALID_DATA
	
	data.merge(binary_data as Dictionary,true)
	return OK
	
func _open_file_for_write(file_path:String,create_dir:bool) -> Array:
	var err:Error = _check_and_create_dir(file_path,create_dir)
	if err != OK:
		return [err,null]
	
	var file: FileAccess = FileAccess.open(file_path,FileAccess.WRITE)
	if file == null:
		return [FileAccess.get_open_error(),null]
	return [OK, file]
	
func _open_file_for_read(file_path:String) -> Array:
	if not FileAccess.file_exists(file_path):
		return [ERR_FILE_NOT_FOUND,null]
	var file:FileAccess = FileAccess.open(file_path,FileAccess.READ)
	if file == null:
		return [FileAccess.get_open_error(),null]
	return [OK, file]

func _check_and_create_dir(file_path:String,create_dir:bool) -> Error:
	var dir_path: String = file_path.get_base_dir()
	if DirAccess.dir_exists_absolute(dir_path):
		return OK
	if not create_dir:
		return ERR_CANT_CONNECT
	return DirAccess.make_dir_recursive_absolute(dir_path)
