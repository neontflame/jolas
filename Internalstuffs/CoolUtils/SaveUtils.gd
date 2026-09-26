extends Node
class_name SaveUtils

static func save_game(slot:int):
	if GPStats.is_dedicated_server: return
	var playstime = 0.0
	
	if get_save_info(slot)['new'] == true || !get_save_info(slot)['first-playtime']:
		playstime = Time.get_unix_time_from_system()
	else:
		playstime = get_save_info(slot)['first-playtime']
	var saveStuff
	if ModUtils.loadedMods != []:
		saveStuff = FileAccess.open(get_save_path(slot, true), FileAccess.WRITE)
	else:
		saveStuff = FileAccess.open(get_save_path(slot), FileAccess.WRITE)
	var saveInfo:Dictionary = {
		"new": false,
		"player": GPStats.char,
		"level": GPStats.level,
		"xp": GPStats.xp,
		"maxHP": GPStats.maxHP,
		"map": GPStats.curMap,
		"region": GPStats.curRegion,
		"exploredMaps": GPStats.exploredMaps,
		"inventory": InventoryUtils.inventory,
		"first-playtime": playstime,
		"last-playtime": Time.get_unix_time_from_system(),
		"assignedQuests": QuestUtils.assignedQuests,
		"clearedQuests": QuestUtils.clearedQuests,
		"applied-mods": ModUtils.loadedModsFolderless
	}
	
	saveStuff.store_string(JSON.stringify(saveInfo))
	
static func get_save_info(slot:int):
	var newSave = {
		"new": true
	}
	var pathness:String = get_save_path(slot)
	var pathnessMods:String = get_save_path(slot, true)
	var shouldMod:bool = (FileAccess.file_exists(pathnessMods) && ModUtils.loadedMods != [])
	
	if !shouldMod:
		if !FileAccess.file_exists(pathness):
			return newSave
		
	var saveStuff = FileAccess.open((pathnessMods if shouldMod else pathness), FileAccess.READ)
	var saveGotten = JSON.parse_string(saveStuff.get_as_text())
	
	if not saveGotten.has("region"):
		saveGotten["region"] = GameUtils.get_region_from_map(saveGotten["map"])
	return saveGotten

static func delete_save(slot:int):
	var pathness:String = get_save_path(slot)
	var pathnessMods:String = get_save_path(slot, true)
	
	var shouldMod:bool = (ModUtils.loadedMods != [])
	
	var saveStuff = FileAccess.open((pathnessMods if shouldMod else pathness), FileAccess.WRITE)
	var saveInfo:Dictionary = {
		"new": true,
		"deleted": true
	}
	
	saveStuff.store_string(JSON.stringify(saveInfo))

static func save_online():
	var saveStuff = FileAccess.open(get_online_info_path(), FileAccess.WRITE)
	var saveInfo:Dictionary = {
		"name": OnlineUtils.username,
		"ip": OnlineUtils.ipEntered,
		"port": int(OnlineUtils.portEntered),
		"serverName": OnlineUtils.serverName,
		"saveSlot": GPStats.saveSlot,
		"char": GPStats.char
	}
	
	saveStuff.store_string(JSON.stringify(saveInfo))

static func get_online_info():
	var pathness:String = get_online_info_path()
	var emptyInfo:Dictionary = {
		"name": "",
		"ip": "127.0.0.1",
		"port": 7000,
		"serverName": "",
		"saveSlot": 0,
		"char": "Neon"
	}
	
	if !FileAccess.file_exists(pathness):
		return emptyInfo
		
	var saveStuff = FileAccess.open(pathness, FileAccess.READ)
	var saveGotten = emptyInfo
	saveGotten.merge(JSON.parse_string(saveStuff.get_as_text()), true)
	if saveGotten.has('char'):
		saveGotten['char'] = GameUtils.existing_char(saveGotten['char'])
	else:
		saveGotten['char'] = 'Neon'
	return saveGotten

static func get_online_info_path():
	return '%sonlineInfo.json' % FileUtils.get_user_path()

static func get_save_path(slot:int, modded:bool = false):
	if modded:
		return '%smodSave%s.jol' % [FileUtils.get_user_path(), slot]
	return '%ssave%s.jol' % [FileUtils.get_user_path(), slot]
