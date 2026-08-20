extends Node
class_name GameUtils

static var isMobile:bool = false
static var testingMobile:bool = false

static var loadedMods:Array = []
static var loadedModsFolderless:Array = []
static var queuedMods:Array = []

static var ipEntered:String = '127.0.0.1'
static var portEntered:int = 7000
static var username:String = ''

static var defaultMap:String = 'TheThing'

static var charOrder:Array = ['Neon', 'Sushi', 'GTeto', 'Sketcher', 'Henry', 'FknDavid', 'Onerb', 'Espy', 'Queixao']

static var majorVersion:int = 0
static var minorVersion:int = 10
static var patchVersion:int = 0
static var captionVersion:String = ''
static var gameVersion:String = '%s.%s.%s' % [majorVersion, minorVersion, patchVersion]

static func get_chars():
	var charlist:Array = ResourceLoader.list_directory("res://Playerstuffs/Characters/")
	var trueCharlist:Array = charOrder
	
	# checa se existe
	for chara in charlist:
		var coolswag = chara.left(len(chara) - 1)
		if ResourceLoader.exists(get_char_asset_path(coolswag, coolswag + '.tscn')):
			if not trueCharlist.has(coolswag):
				trueCharlist.append(coolswag)
		else:
			if trueCharlist.has(coolswag):
				trueCharlist.erase(coolswag)
	
	# checa se tem
	for chara in charlist:
		var coolswag = chara.left(len(chara) - 1)
		if get_char_info(coolswag).has("locked"):
			print(coolswag, ' e desbloqueavel')
			if not UnlockUtils.is_char_unlocked(coolswag):
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

#region Chars
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
#endregion

#region Mapas
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
#endregion

#region Itens
static func get_item_info(item:String):
	var itemStuff = get_item_asset_path(item, "Info.json")
	var itemInfo = '' 
	if !ResourceLoader.exists(itemStuff):
		itemInfo = '{
	"name": "Placeholder",
	"desc": "Esse item lorem ipsum dolor sit amet"
	}'
	else:
		itemInfo = FileUtils.get_text_file_content(itemStuff)
	var itemGotten = JSON.parse_string(itemInfo)
	return itemGotten

static func get_item_asset(item:String, asset:String):
	var itemPath = get_item_asset_path(item, asset)
	# print(itemPath + (" exists" if load(itemPath) else " doesnt exist"))
	if ResourceLoader.exists(itemPath):
		return load(itemPath)
	else:
		return null
	
static func get_item_asset_path(item:String, asset:String):
	var itemPath = "res://Gamestuffs/Itemstuffs/" + item + "/" + asset
	return FileUtils.get_localized_file(itemPath)
#endregion
