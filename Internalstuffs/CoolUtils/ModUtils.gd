extends Node
class_name ModUtils

static var loadedMods:Array = []
static var queuedMods:Array = []

static func get_mod_path(mod:String, asset:String = "mod.pck"):
	return '%s/mods/%s/%s' % [FileUtils.get_user_path(), mod, asset]

static func get_mod_info(mod:String):
	# mods serao .pck ou .zip
	var modStuff = '%s/mods/%s/metadata.json' % [FileUtils.get_user_path(), mod]
	var modInfo = '' 
	if !FileAccess.file_exists(modStuff):
		modInfo = '{
		"name": "MeuModSuperLegal",
		"author": "epicojogos123",
		"restartsGame": false,
		"requiredVersion": "%s",
		"runOnLoad": []
		}' % GameUtils.gameVersion
	else:
		modInfo = FileUtils.get_text_file_content(modStuff)
	var modGotten = JSON.parse_string(modInfo)
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
