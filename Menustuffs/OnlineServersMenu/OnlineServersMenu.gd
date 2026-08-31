extends "res://Menustuffs/Submenu.gd"
class_name OnlineServersMenu

var canControl:bool = true

@export var servRequest:HTTPRequest
@export var servContainer:VBoxContainer
var selectedThing

func _ready() -> void:
	CoolMenu.blurAmount = 2
	CoolMenu.activeMusicLayers = 3
	servRequest.request("%s/servers.php?mods=true" % OnlineUtils.masterServer)

func _enter_tree() -> void:
	if !GPStats.is_multiplayer:
		GPStats.saveNum = SaveUtils.get_online_info()['saveSlot']
		GPStats.char = SaveUtils.get_online_info()['char']
	GPStats.is_multiplayer = true
	
	$MenuCanvas/MidAnchor/ServlistLabel.text = "Lista de servidores (%s)" % OnlineUtils.masterServer

func _process(delta: float) -> void:
	if !canControl: return
	
	for coolOpt in servContainer.get_children():
		if CoolMenu.curSelected != -1:
			coolOpt.selected = (coolOpt.id == CoolMenu.curSelected)
			selectedThing = coolOpt
		else:
			coolOpt.selected = false
	if CoolMenu.curSelected == -1:
		selectedThing = null
	
	if Input.is_action_just_pressed("ui_down"):
		CoolMenu.curSelected = wrap(CoolMenu.curSelected + 1, 0, CoolMenu.maxSelected)
		$MenuCanvas/MidAnchor/ScrollContainer.scroll_vertical = servContainer.get_children()[CoolMenu.curSelected].position.y
		CoolMenu.play_sfx('Tick')
	
	if Input.is_action_just_pressed("ui_up"):
		CoolMenu.curSelected = wrap(CoolMenu.curSelected - 1, 0, CoolMenu.maxSelected)
		$MenuCanvas/MidAnchor/ScrollContainer.scroll_vertical = servContainer.get_children()[CoolMenu.curSelected].position.y
		CoolMenu.play_sfx('Tick')
	
	if Input.is_action_just_pressed("ui_accept"):
		if selectedThing:
			goToGame(selectedThing.metadata["ip"], selectedThing.metadata["port"])
	
	if Input.is_action_just_pressed("ui_cancel"):
		CoolMenu.play_sfx('Back')
		change_self_scene('res://Menustuffs/OnlineMenu/OnlineMenu.tscn')
	
	MultiplayerMayhem.player_info["name"] = OnlineUtils.username

var mapToGoTo := ''

func goToGame(ip:String, port:int):
	OnlineUtils.ipEntered = ip
	OnlineUtils.portEntered = port
	GPStats.is_hosting = false
	
	canControl = false
	CoolMenu.activeMusicLayers = 0
	CoolMenu.play_sfx('Go')
	
	if SaveUtils.get_save_info(GPStats.saveNum)['new'] == true:
		mapToGoTo = GameUtils.defaultMap
	else:
		mapToGoTo = SaveUtils.get_save_info(GPStats.saveNum)['map']
		
	GPStats.load_info_from_save(GPStats.saveNum)
	
	var coolTweens = create_tween()
	coolTweens.tween_method(
					func(value): 
						$MenuCanvas/FadeRect.self_modulate.a = value
						if value >= 1:
							GeneralUtils.loadScene("res://Gamestuffs/Game.tscn")
						,  
					0.0,  # Start value
					1.0,  # End value
					0.5    # Duration
				)

func requestDone(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var coolBodyes:String = ""
	var coolDicts:Dictionary = {}
	if result == HTTPRequest.RESULT_SUCCESS:
		coolBodyes = body.get_string_from_utf8()
		coolDicts = JSON.parse_string(coolBodyes)
		
		for child in servContainer.get_children():
			child.free()
		
		var whichOne:int = 0
		for server in coolDicts.servers:
			print('serv: ', server)
			var newServy = load("res://Menustuffs/OnlineServersMenu/ServerThingie.tscn").instantiate()
			servContainer.add_child(newServy)
			newServy.setup(whichOne, server)
			newServy.heyImPressed.connect(func(id, metadata):
				goToGame(metadata.ip, metadata.port)
			)
			whichOne += 1
		
		CoolMenu.maxSelected = len(coolDicts.servers)
