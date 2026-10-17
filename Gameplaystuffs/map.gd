@tool
@icon("uid://c33sc3mggdipf")
extends Node2D
class_name JolasMap

# agora nos so usamos os nomes dos nodes mesmo #Lol
# @export var spawnpoint:Node2D
# @export var spawnpointBack:Node2D
var info:MapInfo = null

func _ready() -> void:
	if get_tree().current_scene.name == name:
		await GameInit.setupGameInfo()
		GPStats.curMap = name
		GPStats.curRegion = GameUtils.get_region_from_map(GPStats.curMap)
		GPStats.char = GameUtils.get_chars().pick_random()
		GPStats.saveSlot = 999
		GeneralUtils.loadScene("res://Gamestuffs/Game.tscn")
		return
	MapUtils.set_map(self)
