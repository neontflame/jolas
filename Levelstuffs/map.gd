extends Node2D
class_name JolasMap

@export var spawnpoint:Node2D
@export var spawnpointBack:Node2D

func _ready() -> void:
	if get_tree().current_scene.name == name:
		await GameInit.setupGameInfo()
		var mapName = get_tree().current_scene.scene_file_path.get_file().get_basename()
		GPStats.curMap = mapName
		GPStats.char = GameUtils.get_chars().pick_random()
		GPStats.saveNum = 999
		get_tree().change_scene_to_file("res://Gamestuffs/Game.tscn")
		return
	MapUtils.set_map(self)
