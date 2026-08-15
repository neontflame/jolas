extends Node2D
class_name JolasMap

# agora nos so usamos os nomes dos nodes mesmo #Lol
# @export var spawnpoint:Node2D
# @export var spawnpointBack:Node2D
@export var infoCoisos:String = ""

@export var hasBossRoom:bool = false
@export var boss:BossObject
@export var bossRoom:Area2D
var allPlayersInBossRoom:bool = false

func _ready() -> void:
	if get_tree().current_scene.name == name:
		await GameInit.setupGameInfo()
		var mapName = get_tree().current_scene.scene_file_path.get_file().get_basename()
		GPStats.curMap = mapName
		GPStats.char = GameUtils.get_chars().pick_random()
		GPStats.saveNum = 999
		GeneralUtils.loadScene("res://Gamestuffs/Game.tscn")
		return
	MapUtils.set_map(self)
	await get_tree().process_frame
	await get_tree().process_frame
	if hasBossRoom:
		bossRoom.body_entered.connect(onEnterBossRoom)

func onEnterBossRoom(body:Node2D):
	for player in JolasGame.instance.allChars:
		if GPStats.is_multiplayer and (player.curMap != GPStats.curMap):
			return
		if not bossRoom.get_overlapping_bodies().has(player):
			print('[JOLASMAP] Ih crl')
			return
	
	if not allPlayersInBossRoom:
		print('[JOLASMAP] FOI')
		boss.awake()
		bossStart()
		allPlayersInBossRoom = true

func bossStart():
	pass

func bossEnd():
	pass
