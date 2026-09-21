extends Node
class_name GameUtils

static var isMobile:bool = false
static var testingMobile:bool = false

static var majorVersion:int = 0
static var minorVersion:int = 10
static var patchVersion:int = 0
static var captionVersion:String = 'Demo'
static var gameVersion:String = '%s.%s.%s' % [majorVersion, minorVersion, patchVersion]

#region Chars
static var charOrder:Array = ['Neon', 'Sushi', 'GTeto', 'Sketcher', 'Henry', 'FknDavid', 'Onerb', 'Espy', 'Queixao']

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
		if get_char_info(coolswag).locked:
			print(coolswag, ' e desbloqueavel')
			if not UnlockUtils.is_char_unlocked(coolswag):
				trueCharlist.erase(coolswag)
		
	return trueCharlist

static func get_char_preview(char:String):
	return get_char_asset(char, 'CharSel.tscn')

static func get_char_info(char:String):
	var charStuff = get_char_asset_path(char, "Info.tres")
	var charInfo:PlayerInfo = PlayerInfo.new()
	if ResourceLoader.exists(charStuff):
		charInfo = load(charStuff)
	return charInfo

static func get_char_asset(char:String, asset:String):
	var charPath = get_char_asset_path(char, asset)
	if ResourceLoader.exists(charPath):
		return load(charPath)
	else:
		return null
	
static func get_char_asset_path(char:String, asset:String):
	var charPath = "res://Playerstuffs/Characters/%s/%s" % [existing_char(char), asset]
	return FileUtils.get_localized_file(charPath)
	
static func existing_char(char:String):
	if ResourceLoader.list_directory("res://Playerstuffs/Characters/%s/" % char): return char
	else: return 'Neon'
#endregion

#region Mapas
static var defaultMap:String = 'TheThing'

static var infoCache:Dictionary = {}
#eu nao acho que nos precisamos disso a nao ser que eu faça um menu de level select depois
#static func get_maps():
	#var lvlList:Array = ResourceLoader.list_directory("res://Gameplaystuffs/Levels/")
	#var trueLvlList:Array = []
	#for lvl in lvlList:
		#if lvl.substr(len(lvl) - 5, 5) == '.json':
			## KILL THEM .
			#pass
		#else:
			#trueLvlList.append(lvl.left(len(lvl) - 5))
	#return trueLvlList

static func get_region_info(region:String):
	var regionStuff = get_region_asset_path(region, "Region.tres")
	var regionInfo = RegionInfo.new()
	if ResourceLoader.exists(regionStuff):
		regionInfo = load(regionStuff)
	return regionInfo

static func get_region_asset(region:String, asset:String):
	var regionPath = get_region_asset_path(region, asset)
	if ResourceLoader.exists(regionPath):
		return load(regionPath)
	else:
		return null
	
static func get_region_asset_path(region:String, asset:String):
	var regionPath = "res://Gameplaystuffs/Levels/%s/%s" % [region, asset]
	return FileUtils.get_localized_file(regionPath)

static func get_region_from_map(map: String):
	var levels_path := "res://Gameplaystuffs/Levels"
	for region in ResourceLoader.list_directory(levels_path):
		if region.ends_with("/"):
			region = region.trim_suffix("/")
			if ResourceLoader.exists("%s/%s/%s/Map.tscn" % [levels_path, region, map]):
				return region
	return null

static func get_map_path(map:String, region:String = ""):
	if region == "":
		region = get_region_from_map(map)
	return "res://Gameplaystuffs/Levels/%s/%s/Map.tscn" % [region, map]

static func get_map_info(map:String, region:String = ""):
	if infoCache.has("%s/%s" % [region, map]):
		return infoCache["%s/%s" % [region, map]]
		
	if region == "":
		region = get_region_from_map(map)
	
	var mapStuff = get_region_asset_path(region, map + "/Info.tres")
	var mapInfo = MapInfo.new()
	if ResourceLoader.exists(mapStuff):
		mapInfo = load(mapStuff)
		mapInfo.region = get_region_info(region)
		
		infoCache["%s/%s" % [region, map]] = mapInfo
	return mapInfo
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
	var itemPath = "res://Gameplaystuffs/Items/" + item + "/" + asset
	return FileUtils.get_localized_file(itemPath)
#endregion
