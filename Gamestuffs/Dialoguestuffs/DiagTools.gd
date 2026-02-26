extends Node
class_name DiagTools

static func get_portrait(char:String):
	var possibilities:Array = [
		GameUtils.get_char_asset_path(char, 'Portrait.tscn'),
		"res://Gamestuffs/NPCs/?/Portrait.tscn"
	]
	for possible in possibilities:
		possible = possible.replace('?', char)
		if ResourceLoader.exists(possible):
			return load(possible)
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
