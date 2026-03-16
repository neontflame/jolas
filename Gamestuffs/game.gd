extends Node2D
class_name JolasGame

var level:JolasLevel
var playerInstance
var dialogueInstance
var isDial := false

var allChars:Array = []
var charDict:Dictionary = {}

@export var coolFade:TextureRect
@export var plyNode:Node2D
@export var lvlNode:Node2D
@export var hud:HeadsUpDisplay
@export var bgmStream:AudioStreamPlayer

var curTrackName:String = ""

static var instance:JolasGame

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	createLevel(GPStats.curMap)
	createPlayer(GPStats.char, -1)
	SaveUtils.save_game(GPStats.saveNum)
	
	if GPStats.is_multiplayer:
		if GPStats.is_hosting:
			create_mp_game()
		else:
			join_mp_game()
	
	JolasGame.instance = self

#region Os Auxiliares
# The Joy of Creation
# eu nunca joguei fnaf na minha vida na vdd
func createPlayer(chara:String, id:int = -1):
	var player = GameUtils.get_char_asset(chara, chara + ".tscn")
	
	if playerInstance: remove_child(playerInstance)
	playerInstance = player.instantiate()
	playerInstance.playerID = id
	plyNode.add_child(playerInstance)
	allChars.append(playerInstance)
	
	if level:
		playerInstance.position = level.spawnpoint.position
		
	GPStats.setCharObject(playerInstance)

func removePlayer():
	if playerInstance: 
		allChars.erase(playerInstance)
		playerInstance.queue_free()

func createLevel(lvl:String):
	if level: level.queue_free()
	
	level = load(GameUtils.get_map_path(lvl)).instantiate()
	lvlNode.add_child(level)
	
	GPStats.curMap = level.name
	SaveUtils.save_game(GPStats.saveNum)
	if GameUtils.get_map_info(lvl).has('songFile'):
		playBGM(GameUtils.get_map_info(lvl)['songFile'])
		
	hud.placeInfo.queue_free()
	hud.placeInfo = load("res://Gamestuffs/HeadsUpDisplay/placeInfo.tscn").instantiate()
	hud.get_node("CanvasLayer/Control").add_child(hud.placeInfo)
	hud.placeInfo.position = Vector2(20.0, 21.0)
	hud.placeInfo.triggerPlaceInfo()

func respawnPlayer(maxOutHP:bool = true, comeback:bool = false):
	if level:
		GPStats.charObject.position = (level.spawnpointBack.position if comeback else level.spawnpoint.position)
	
	if maxOutHP: GPStats.charObject.hp = GPStats.maxHP
	GPStats.charObject.change_state(GPStats.charObject.state_machine.st_floor)

#acaba os treco de player
var fadeTween:Tween = create_tween()
func fadeOut(sec:float, callThat:Callable = func():pass):
	fadeTween.kill()
	
	fadeTween = create_tween()
	fadeTween.tween_method(
		func(value): 
			coolFade.self_modulate.a = value
			if value <= 0.0:
				coolFade.visible = false
				callThat.call()
			,  
		1.0,  # Start value
		0.0,  # End value
		sec     # Duration
	)

func fadeIn(sec:float, callThat:Callable = func():pass):
	fadeTween.kill()
	
	coolFade.visible = true
	fadeTween = create_tween()
	fadeTween.tween_method(
		func(value): 
			coolFade.self_modulate.a = value
			if value >= 1.0:
				callThat.call()
			,  
		0.0,  # Start value
		1.0,  # End value
		sec     # Duration
	)

func pauseGame():
	for playery in allChars:
		playery.movementEnabled = false
	for child in get_children():
		if child == dialogueInstance: continue
		child.process_mode = PROCESS_MODE_DISABLED

func unpauseGame():
	for playery in allChars:
		playery.movementEnabled = playery.get_multi_status()
	for child in get_children():
		if child == dialogueInstance: continue
		child.process_mode = PROCESS_MODE_INHERIT
#endregion

#region Diálogo
# DIALOGO....
func endDialogue() -> void:
	isDial = false
	unpauseGame()
	dialogueInstance.disconnect('dialogue_end', endDialogue)
	remove_child(dialogueInstance)

func playDialogue(diagName:String):
	if !isDial:
		isDial = true
		pauseGame()
		if dialogueInstance: dialogueInstance.queue_free()
		dialogueInstance = load("res://Gamestuffs/Dialoguestuffs/DialogueScene.tscn").instantiate()
		add_child(dialogueInstance)
		dialogueInstance.parseDialogue(diagName)
		dialogueInstance.connect('dialogue_end', endDialogue)
#endregion

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	GPStats.process(_delta)
	pass
	
#region Multiplayer
func join_mp_game():
	removePlayer()
	removeFromPeerID(multiplayer.get_unique_id())
	$Multiplayer.join_game(GameUtils.ipEntered)

func create_mp_game():
	removePlayer()
	removeFromPeerID(multiplayer.get_unique_id())
	$Multiplayer.create_game()

func _on_player_connected(peer_id: Variant, player_info: Variant) -> void:
	removeFromPeerID(peer_id)
	var playery = GameUtils.get_char_asset(player_info['char'], player_info['char'] + ".tscn")
	var pInst = playery.instantiate()
	pInst.playerID = peer_id
	pInst.name = str(peer_id)
	plyNode.add_child(pInst, true)
	allChars.append(pInst)
	charDict[peer_id] = pInst
	
	if level:
		pInst.position = level.spawnpoint.position
		
	pInst.movementEnabled = pInst.get_multi_status()
	print('== CHAR DICT ==')
	print(charDict)
	print('== END CHAR DICT ==')

func _on_player_disconnected(peer_id: Variant) -> void:
	removeFromPeerID(peer_id)

func removeFromPeerID(peer_id:Variant):
	if charDict.has(peer_id):
		allChars.erase(charDict[peer_id])
		charDict[peer_id].queue_free()
		charDict.erase(peer_id)

func bye_bye() -> void:
	CoolMenu.comingFrom = 'OnlineMenu'
	get_tree().change_scene_to_file("res://Menustuffs/Menu.tscn")
#endregion

#region Música
func playBGM(trackName:String):
	var pathness = "res://Musicstuffs/" + trackName
	if curTrackName == trackName: return
	curTrackName = trackName
	
	bgmStream.stream = load(pathness)
	bgmStream.play()
	bgmStream.finished.connect(func():curTrackName="")
#endregion
