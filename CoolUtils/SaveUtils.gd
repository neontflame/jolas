extends Node
class_name SaveUtils

static func save_game(slot:int):
	var playstime = 0.0
	
	if get_save_info(slot)['new'] == true || !get_save_info(slot)['first-playtime']:
		playstime = Time.get_unix_time_from_system()
	else:
		playstime = get_save_info(slot)['first-playtime']
		
	var saveStuff = FileAccess.open('user://save' + str(slot) + '.jol', FileAccess.WRITE)
	var saveInfo:Dictionary = {
		"new": false,
		"player": GPStats.char,
		"level": GPStats.level,
		"xp": GPStats.xp,
		"maxHP": GPStats.maxHP,
		"map": MapUtils.map.name,
		"first-playtime": playstime,
		"last-playtime": Time.get_unix_time_from_system()
	}
	
	saveStuff.store_string(JSON.stringify(saveInfo))
	
static func get_save_info(slot:int):
	var newSave = {
		"new": true
	}
	var pathness:String = 'user://save' + str(slot) + '.jol'
	
	if !FileAccess.file_exists(pathness):
		return newSave
		
	var saveStuff = FileAccess.open(pathness, FileAccess.READ)
	var saveGotten = JSON.parse_string(saveStuff.get_as_text())
	return saveGotten

static func delete_save(slot:int):
	var saveStuff = FileAccess.open('user://save' + str(slot) + '.jol', FileAccess.WRITE)
	var saveInfo:Dictionary = {
		"new": true,
		"deleted": true
	}
	
	saveStuff.store_string(JSON.stringify(saveInfo))
