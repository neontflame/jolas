extends Node
class_name DiagUtils

static func get_dialogue_path(diag:String):
	var pathness:String = FileUtils.get_localized_file('res://Gamestuffs/Dialoguestuffs/Dialogues/%s.json' % diag)
	var pathness_char:String = FileUtils.get_localized_file('res://Gamestuffs/Dialoguestuffs/Dialogues/%s.%s.json' % [diag, GPStats.char])
	
	if ResourceLoader.exists(pathness_char):
		return pathness_char
	else:
		return pathness

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
