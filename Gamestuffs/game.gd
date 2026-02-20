extends Node2D
class_name JolasGame

var level:JolasLevel
var playerInstance
var dialogueInstance
var isDial := false

var allChars:Array = []
var charDict:Dictionary = {}

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

# The Joy of Creation
# eu nunca joguei fnaf na minha vida na vdd
func createPlayer(chara:String, id:int = -1):
	var player = GameUtils.get_char_asset(chara, chara + ".tscn")
	
	if playerInstance: remove_child(playerInstance)
	playerInstance = player.instantiate()
	playerInstance.playerID = id
	add_child(playerInstance)
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
	add_child(level)
	
	GPStats.curMap = level.name

# DIALOGO....
func endDialogue() -> void:
	isDial = false
	for playery in allChars:
		playery.movementEnabled = playery.get_multi_status()
		playery.process_mode = PROCESS_MODE_INHERIT
	dialogueInstance.disconnect('dialogue_end', endDialogue)
	remove_child(dialogueInstance)

func playDialogue(diagName:String):
	if !isDial:
		isDial = true
		for playery in allChars:
			playery.movementEnabled = false
			playery.process_mode = PROCESS_MODE_DISABLED
		if dialogueInstance: remove_child(dialogueInstance)
		dialogueInstance = load("res://Gamestuffs/Dialoguestuffs/DialogueScene.tscn").instantiate()
		add_child(dialogueInstance)
		dialogueInstance.parseDialogue(diagName)
		dialogueInstance.connect('dialogue_end', endDialogue)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	GPStats.process(_delta)
	
	if (Input.is_action_just_pressed("ui_accept")):
		playDialogue('diagTool')
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
	add_child(pInst, true)
	allChars.append(pInst)
	charDict[peer_id] = pInst
	
	if level:
		pInst.position = level.spawnpoint.position
		
	pInst.movementEnabled = pInst.get_multi_status()
	print(charDict)

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
