extends Node
class_name GPStats

static var saveNum := 0

static var char := 'Neon'
static var xp := 0
static var level := 3
static var charObject:PlayerObject
static var maxHP := 10
static var lvLimit := 5 # multiplicador pros limites dos niveis eu acho
static var curMap := 'TheThing'

static var modded := false

#region Multiplayer variables
static var is_multiplayer := false
static var is_hosting := false
static var multiplayerID:Variant = -1
#endregion

static func setCharObject(thisChar:PlayerObject):
	charObject = thisChar

static func process(delta: float) -> void:
	if xp > level * lvLimit:
		xp = xp - level * lvLimit
		level += 1

static func load_info_from_save(saveNum:int):
	var save = SaveUtils.get_save_info(saveNum)
	
	if save['new'] == true:
		level = 1
		xp = 0
		maxHP = 10
		curMap = GameUtils.defaultMap
	else:
		level = save['level']
		xp = save['xp']
		maxHP = save['maxHP']
		curMap = save['map']
