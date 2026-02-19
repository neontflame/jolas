extends Node
class_name SaveUtils

static func save_game(slot:int):
	var playstime = 0.0
	
	if get_save_info(slot)['new'] == true || !get_save_info(slot)['first-playtime']:
		playstime = Time.get_unix_time_from_system()
	else:
		playstime = get_save_info(slot)['first-playtime']
	var saveStuff
	if GameUtils.loadedMods != []:
		saveStuff = FileAccess.open('user://modSave' + str(slot) + '.jol', FileAccess.WRITE)
	else:
		saveStuff = FileAccess.open('user://save' + str(slot) + '.jol', FileAccess.WRITE)
	var saveInfo:Dictionary = {
		"new": false,
		"player": GPStats.char,
		"level": GPStats.level,
		"xp": GPStats.xp,
		"maxHP": GPStats.maxHP,
		"map": MapUtils.map.name,
		"first-playtime": playstime,
		"last-playtime": Time.get_unix_time_from_system(),
		"applied-mods": GameUtils.loadedMods
	}
	
	saveStuff.store_string(JSON.stringify(saveInfo))
	
static func get_save_info(slot:int):
	var newSave = {
		"new": true
	}
	var pathness:String = 'user://save' + str(slot) + '.jol'
	var pathnessMods:String = 'user://modSave' + str(slot) + '.jol'
	var shouldMod:bool = (FileAccess.file_exists(pathnessMods) && GameUtils.loadedMods != [])
	
	if !shouldMod:
		if !FileAccess.file_exists(pathness):
			return newSave
		
	var saveStuff = FileAccess.open((pathnessMods if shouldMod else pathness), FileAccess.READ)
	var saveGotten = JSON.parse_string(saveStuff.get_as_text())
	return saveGotten

static func delete_save(slot:int):
	var pathness:String = 'user://save' + str(slot) + '.jol'
	var pathnessMods:String = 'user://modSave' + str(slot) + '.jol'
	
	var shouldMod:bool = (GameUtils.loadedMods != [])
	
	var saveStuff = FileAccess.open((pathnessMods if shouldMod else pathness), FileAccess.WRITE)
	var saveInfo:Dictionary = {
		"new": true,
		"deleted": true
	}
	
	saveStuff.store_string(JSON.stringify(saveInfo))
