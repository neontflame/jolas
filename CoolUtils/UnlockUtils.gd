extends Node
class_name UnlockUtils

static var unlockedChars:Array = []

static func is_char_unlocked(charName:StringName):
	return unlockedChars.has(charName)
	
static func unlock_char(charName:StringName):
	if not unlockedChars.has(charName): unlockedChars.append(charName)
	save_unlocks()
	
static func save_unlocks():
	var saveStuff = FileAccess.open('user://unlocks.jol', FileAccess.WRITE)
	var saveInfo:Dictionary = {
		"chars": unlockedChars
	}
	
	saveStuff.store_string(JSON.stringify(saveInfo))

static func get_unlocks():
	var pathness:String = 'user://unlocks.jol'
	var emptyInfo:Dictionary = {
		"chars": []
	}
	
	if !FileAccess.file_exists(pathness):
		return emptyInfo
		
	var unlockStuff = FileAccess.open(pathness, FileAccess.READ)
	var unlockRetrieve = JSON.parse_string(unlockStuff.get_as_text())
	return unlockRetrieve

static func merge_to_vars():
	for char in get_unlocks()["chars"]:
		unlockedChars.append(char)
