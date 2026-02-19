extends Node
class_name GameUtils

static func get_chars():
	var charlist:Array = ResourceLoader.list_directory("res://Playerstuffs/Characters/")
	var trueCharlist:Array = []
	
	for char in charlist:
		trueCharlist.append(char.left(len(char) - 1))
		
	return trueCharlist
	
static func get_maps():
	var lvlList:Array = ResourceLoader.list_directory("res://Gamestuffs/Levelstuffs/Levels/")
	var trueLvlList:Array = []
	
	for lvl in lvlList:
		if lvl.substr(len(lvl) - 5, 5) == '.json':
			# KILL THEM .
			pass
		else:
			trueLvlList.append(lvl.left(len(lvl) - 5))
		
	return trueLvlList

static func get_char_preview(char:String):
	return load("res://Playerstuffs/Characters/" + existing_char(char) + "/CharSel.tscn")
	
static func get_char_info(char:String):
	var charStuff = "res://Playerstuffs/Characters/" + existing_char(char) + "/Info.json"
	var charInfo = '' 
	if load(charStuff) == null:
		charInfo = '{
	"name": "Placeholder",
	"desc": "Lorem ipsum dolor sit amet",
	"ability": "o que ele sequer [wave]faz ?[/wave]"
	}'
	else:
		charInfo = FileUtils.get_text_file_content(charStuff)
	var charGotten = JSON.parse_string(charInfo)
	return charGotten

static func get_char_asset(char:String, asset:String):
	var charPath = "res://Playerstuffs/Characters/" + existing_char(char) + "/" + asset
	print(charPath + (" exists" if load(charPath) else " doesnt exist"))
	var charStuff = load(charPath)
	return charStuff

static func existing_char(char:String):
	if ResourceLoader.list_directory("res://Playerstuffs/Characters/" + char + "/"): return char
	else: return 'Neon'
	
static func get_map_info(lvl:String):
	var lvlStuff = "res://Gamestuffs/Levelstuffs/Levels/" + lvl + ".json"
	var lvlInfo = ''
	if load(lvlStuff) == null:
		lvlInfo = '{
	"name": "Tapa-buraco",
	"region": "Place Holder"
}'
	else:
		lvlInfo = FileUtils.get_text_file_content(lvlStuff)
	var lvlGotten = JSON.parse_string(lvlInfo)
	return lvlGotten

static func get_map_path(map:String):
	return "res://Gamestuffs/Levelstuffs/Levels/" + map + ".tscn"
