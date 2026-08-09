extends Node
class_name DiagUtils

static func get_dialogue_path(diag:String):
	var pathness:String = FileUtils.get_localized_file('res://Gamestuffs/Dialoguestuffs/Dialogues/%s.json' % diag)
	var pathness_char:String = FileUtils.get_localized_file('res://Gamestuffs/Dialoguestuffs/Dialogues/%s.%s.json' % [diag, GPStats.char])
	
	if ResourceLoader.exists(pathness_char):
		return pathness_char
	else:
		return pathness

static func get_portrait_path(character:String):
	var possibilities:Array = [
		"res://Gamestuffs/NPCs/%s/Portrait.tscn" % character,
		GameUtils.get_char_asset_path(character, 'Portrait.tscn')
	]
	for possible in possibilities:
		if ResourceLoader.exists(possible):
			return possible
	return null

static func get_portrait(character:String):
	if get_portrait_path(character) != null:
		return load(get_portrait_path(character))
	return null

static func get_coolname(character:String):
	var possibilities:Array = [
		"res://Gamestuffs/NPCs/%s/DiagName.png" % character,
		GameUtils.get_char_asset_path(character, 'DiagName.png')
	]
	for possible in possibilities:
		if ResourceLoader.exists(possible):
			return load(possible)
	return null

static func get_talksound_path(character:String):
	var possibilities:Array = [
		"res://Gamestuffs/NPCs/%s/Talksound.tres" % character,
		GameUtils.get_char_asset_path(character, 'Talksound.tres')
	]
	for possible in possibilities:
		if ResourceLoader.exists(possible):
			return possible
	return null

static func get_talksound(character:String):
	if get_talksound_path(character) != null:
		return load(get_talksound_path(character))
	return null

static func get_voiceline_path(character:String, voiceline:String):
	var possibilities:Array = [
		"res://Gamestuffs/NPCs/%s/Sounds/%s" % [character, voiceline],
		GameUtils.get_char_asset_path(character, 'Sounds/' + voiceline),
		"res://Gamestuffs/Dialoguestuffs/Dialogues/Voicelines/" + voiceline
	]
	var possibleFiletypes:Array = [
		".ogg",
		".wav"
	]
	for theChoicestVoice in possibilities:
		for possible in possibleFiletypes:
			var possibler = FileUtils.get_localized_file(theChoicestVoice + possible)
			if ResourceLoader.exists(possibler):
				return possibler
	return null

static func get_voiceline(character:String, voiceline:String):
	if get_voiceline_path(character, voiceline) != null:
		return load(get_voiceline_path(character, voiceline))
	return null
