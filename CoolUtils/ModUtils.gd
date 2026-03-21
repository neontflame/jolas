extends Node
class_name ModUtils

static func get_mod_info(mod:String):
	# mods serao .pck ou .zip
	var modStuff = mod.left(mod.length() - 3) + 'json'
	var modInfo = '' 
	if !FileAccess.file_exists(modStuff):
		modInfo = '{
		"restartsGame": false,
		"requiredVersion": "%s"
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
