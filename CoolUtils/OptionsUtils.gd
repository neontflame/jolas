extends Node
class_name OptionsUtils

static var preferences:Dictionary = {
}

static var keyBince:Dictionary = {
}

# internalName:String
#visibleName:String
#optionery:Array[String]
#defValue:Variant
static var coolOptiones:Array = [
	['pref', 'Preferências', [], 0], # label
		['buttonType', 'Tipos de botões na UI', ['btn_wii', 'btn_x360', 'btn_ps3', 'btn_gcn', 'btn_dc', 'btn_kb'], 0], #lembre-se de sempre usar o indice e nao o nome em si!
	['vols', 'Volumes', [], 0], # label
		['volMaster', 'Mestre', ['slider'], 1.0],
		['volSFX', 'Efeitos sonoros', ['slider'], 1.0],
		['volBGM', 'Música', ['slider'], 1.0],
	['conts', 'Controles e Gameplay', [], 0], # label
		['tapJump', '"Tap Jump"', ['opt_no', 'opt_yes'], 1],
		['keybinds', 'Keybinds', [''], 0],
		['speedZoom', 'Zoom menor em alta vel.', ['opt_no', 'opt_yes'], 1],
		['genZoom', 'Zoom da câmera', ['slider'], 0.5]
]
static var bindList:Array = [
		["ctrl_left", "Esquerda"],
		["ctrl_down", "Baixo"],
		["ctrl_up", "Cima"],
		["ctrl_right", "Direita"],
		["ctrl_jump", "Pular"],
		["ctrl_2", "Especial 1"], #meio contra-intuitivo mas whatever
		["ctrl_1", "Especial 2"],
		["ctrl_interact", "Interagir"],
		["ctrl_pause", "Pausa"],
		["ctrl_quests", "Quests"]
	]

# Preferencios
static func save_prefs():
	var saveStuff = FileAccess.open('user://preferences.json', FileAccess.WRITE)
	var saveInfo:Dictionary = get_default_prefs()
	saveInfo.merge(preferences, true)
	
	saveStuff.store_string(JSON.stringify(saveInfo))

static func get_prefs_info():
	var pathness:String = 'user://preferences.json'
	var emptyInfo = get_default_prefs()
	
	if !FileAccess.file_exists(pathness):
		return emptyInfo
		
	var saveStuff = FileAccess.open(pathness, FileAccess.READ)
	var saveGotten = JSON.parse_string(saveStuff.get_as_text())
	return saveGotten

static func get_default_prefs() -> Dictionary:
	var emptyDict:Dictionary = {}
	for optione in coolOptiones:
		if optione[2] != []:
			emptyDict.set(optione[0], optione[3]) 
	return emptyDict

# Controles
static func save_controls():
	var saveStuff = FileAccess.open('user://controls.dat', FileAccess.WRITE)
	var saveInfo:Dictionary = get_default_controls()
	saveInfo.merge(keyBince, true)
	
	saveStuff.store_var(saveInfo, true)

static func get_controls_info():
	var pathness:String = 'user://controls.dat'
	var emptyInfo = get_default_controls()
	
	if !FileAccess.file_exists(pathness):
		return emptyInfo
		
	var saveStuff = FileAccess.open(pathness, FileAccess.READ)
	var saveGotten = saveStuff.get_var(true)
	
	for bind in bindList:
		if saveGotten.has(bind[0]):
			keyBince[bind[0]] = saveGotten[bind[0]]
			InputMap.action_erase_events(bind[0])
			InputMap.action_add_event(bind[0], keyBince[bind[0]])
			
	return saveGotten

static func get_default_controls() -> Dictionary:
	var emptyDict:Dictionary = {}
	for bind in bindList:
		keyBince[bind[0]] = InputMap.action_get_events(bind[0])[0]
	return emptyDict
