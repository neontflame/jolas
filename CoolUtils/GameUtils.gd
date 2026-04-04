extends Node
class_name GameUtils

static var loadedMods:Array = []
static var loadedModsFolderless:Array = []
static var queuedMods:Array = []

static var ipEntered:String = '127.0.0.1'
static var portEntered:int = 7000
static var username:String = ''

static var defaultMap:String = 'TheThing'

static var charOrder:Array = ['Neon', 'Sushi', 'GTeto', 'Sketcher', 'Henry']

static var majorVersion:int = 0
static var minorVersion:int = 6
static var patchVersion:int = 0
static var gameVersion:String = '%s.%s.%s' % [majorVersion, minorVersion, patchVersion]

static func get_chars():
	var charlist:Array = ResourceLoader.list_directory("res://Playerstuffs/Characters/")
	var trueCharlist:Array = charOrder
	
	for chara in charlist:
		var coolswag = chara.left(len(chara) - 1)
		if ResourceLoader.exists(get_char_asset_path(coolswag, coolswag + '.tscn')):
			if get_char_info(coolswag).has("locked"):
				if not UnlockUtils.is_char_unlocked(coolswag):
					trueCharlist.erase(coolswag)
			if not trueCharlist.has(coolswag):
				trueCharlist.append(coolswag)
		else:
			if trueCharlist.has(coolswag):
				trueCharlist.erase(coolswag)
		
	return trueCharlist
	
static func get_maps():
	var lvlList:Array = ResourceLoader.list_directory("res://Levelstuffs/Levels/")
	var trueLvlList:Array = []
	
	for lvl in lvlList:
		if lvl.substr(len(lvl) - 5, 5) == '.json':
			# KILL THEM .
			pass
		else:
			trueLvlList.append(lvl.left(len(lvl) - 5))
		
	return trueLvlList

static func get_char_preview(char:String):
	return get_char_asset(char, 'CharSel.tscn')
	
static func get_char_info(char:String):
	var charStuff = get_char_asset_path(char, "Info.json")
	var charInfo = '' 
	if !ResourceLoader.exists(charStuff):
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
	var charPath = get_char_asset_path(char, asset)
	# print(charPath + (" exists" if load(charPath) else " doesnt exist"))
	if ResourceLoader.exists(charPath):
		return load(charPath)
	else:
		return null
	
static func get_char_asset_path(char:String, asset:String):
	var charPath = "res://Playerstuffs/Characters/" + existing_char(char) + "/" + asset
	return FileUtils.get_localized_file(charPath)
	
static func existing_char(char:String):
	if ResourceLoader.list_directory("res://Playerstuffs/Characters/" + char + "/"): return char
	else: return 'Neon'
	
static func get_map_info(lvl:String):
	var lvlStuffOg = "res://Levelstuffs/Levels/" + lvl + ".json"
	var lvlStuff = FileUtils.get_localized_file(lvlStuffOg)
	var lvlInfo = ''
	if !ResourceLoader.exists(lvlStuff):
		lvlInfo = '{
	"name": "Tapa-buraco",
	"region": "Place Holder",
	"regionInternal": "Placeholder",
	"songFile": "Placesong.ogg",
	"song": "Placesong (Remix)"
}'
	else:
		lvlInfo = FileUtils.get_text_file_content(lvlStuff)
	var lvlGotten = JSON.parse_string(lvlInfo)
	return lvlGotten

static func get_map_path(map:String):
	return "res://Levelstuffs/Levels/" + map + ".tscn"
