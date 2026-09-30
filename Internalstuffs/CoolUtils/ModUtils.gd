extends Node
class_name ModUtils

static var loadedMods:Array = []
static var queuedMods:Array = []

static func get_mods_folder():
	return '%s/mods' % FileUtils.get_user_path()

static func get_mod_path(mod:String, asset:String = "mod.pck"):
	return '%s/mods/%s/%s' % [FileUtils.get_user_path(), mod, asset]

static var modInfoCache:Dictionary = {}
static var modPicCache:Dictionary = {}

static func get_mod_pic(mod:String) -> Texture2D:
	if modPicCache.has(mod):
		return modPicCache[mod]
	
	var modStuff = get_mod_path(mod, 'thumb.png')
	var image = Image.load_from_file(modStuff)
	if image:
		var texture = ImageTexture.create_from_image(image)
		modPicCache[mod] = texture
		return texture
	
	return load("res://Miscstuffs/modPlaceholder.png")

static func get_mod_info(mod:String) -> Dictionary:
	if modInfoCache.has(mod):
		return modInfoCache[mod]
	
	# mods serao .pck ou .zip
	var modStuff = get_mod_path(mod, 'metadata.json')
	var modInfo = '{
		"name": "Meu mod Super Legal",
		"author": "epicojogos123",
		"desc": "yeag",
		"restartsGame": false,
		"requiredVersion": "%s",
		"runOnLoad": []
		}' % GameUtils.gameVersion
	
	var modGotten:Dictionary = JSON.parse_string(modInfo)
	if FileAccess.file_exists(modStuff):
		var getModInfo = JSON.parse_string(FileUtils.get_text_file_content(modStuff))
		modGotten.merge(getModInfo, true)
	
	modInfoCache[mod] = modGotten
	return modGotten

static func is_mod_compatible(mod:String):
	var info = get_mod_info(mod)
	# print(info)
	
	var leVers:Dictionary = {
		"major": str(GameUtils.majorVersion),
		"minor": str(GameUtils.minorVersion),
		"patch": str(GameUtils.patchVersion)
	}
	if info.has('requiredVersion'):
		var coolVers = info['requiredVersion'].split('.')
		leVers['major'] = coolVers[0]
		leVers['minor'] = coolVers[1]
		leVers['patch'] = coolVers[2]
	if leVers['major'].is_valid_int():
		if int(leVers['major']) < GameUtils.majorVersion: return false
	if leVers['minor'].is_valid_int():
		if int(leVers['minor']) < GameUtils.majorVersion: return false
	if leVers['patch'].is_valid_int():
		if int(leVers['patch']) < GameUtils.majorVersion: 
			push_warning('Toma cuidado q isso pode quebrar um pouco')
	return true
