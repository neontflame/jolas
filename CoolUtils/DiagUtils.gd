extends Node
class_name DiagUtils

static func get_portrait_path(char:String):
	var possibilities:Array = [
		GameUtils.get_char_asset_path(char, 'Portrait.tscn'),
		"res://Gamestuffs/NPCs/?/Portrait.tscn"
	]
	for possible in possibilities:
		possible = possible.replace('?', char)
		if ResourceLoader.exists(possible):
			return possible
	return null

static func get_portrait(char:String):
	if get_portrait_path(char) != null:
		return load(get_portrait_path(char))
	return null

static func get_coolname(char:String):
	var possibilities:Array = [
		GameUtils.get_char_asset_path(char, 'DiagName.png'),
		"res://Gamestuffs/NPCs/?/DiagName.png"
	]
	for possible in possibilities:
		possible = possible.replace('?', char)
		if ResourceLoader.exists(possible):
			return load(possible)
	return null
