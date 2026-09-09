extends "res://Menustuffs/Submenu.gd"
class_name AttemptConnMenu

static var prevMenu:String = "OnlineMenu"
@export var testingLabel:Label
var canControl:bool = true

func _ready() -> void:
	CoolMenu.blurAmount = 2
	CoolMenu.activeMusicLayers = 3
	MultiplayerMayhem.player_info["connTest"] = true
	testingLabel.text = "Aguarde..."
	tryConnection()

func _process(delta: float) -> void:
	if !canControl: return
	
	if Input.is_action_just_pressed("ui_cancel"):
		canControl = false
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
		goBack()
		
func tryConnection():
	testingLabel.text += "\nTestando conexão com %s:%s" % [OnlineUtils.ipEntered, OnlineUtils.portEntered]
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(OnlineUtils.ipEntered, OnlineUtils.portEntered)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(connSucceed)
	multiplayer.connection_failed.connect(connFailed)

func goBack():
	CoolMenu.play_sfx('Back')
	match prevMenu:
		'OnlineMenu':
			change_self_scene('res://Menustuffs/OnlineMenu/OnlineMenu.tscn')
		'OnlineServersMenu':
			change_self_scene('res://Menustuffs/OnlineMenu/OnlineServersMenu/OnlineServersMenu.tscn')
		_:
			print('bro como que voce sequer fez isso')
			change_self_scene('res://Menustuffs/MainMenu/MainMenu.tscn')

func connFailed():
	testingLabel.text += "\nConexão falhou :("
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	multiplayer.connection_failed.disconnect(connFailed)
	await get_tree().create_timer(0.5).timeout
	goBack()

func connSucceed():
	canControl = false
	testingLabel.text += "\nConectou com sucesso!"
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	multiplayer.connected_to_server.disconnect(connSucceed)
	goToGame()

var mapToGoTo := ''

func goToGame():
	MultiplayerMayhem.player_info["connTest"] = false
	GPStats.is_hosting = false
	
	CoolMenu.activeMusicLayers = 0
	CoolMenu.play_sfx('Go')
	
	if SaveUtils.get_save_info(GPStats.saveSlot)['new'] == true:
		mapToGoTo = GameUtils.defaultMap
	else:
		mapToGoTo = SaveUtils.get_save_info(GPStats.saveSlot)['map']
		
	GPStats.load_info_from_save(GPStats.saveSlot)
	
	var coolTweens = create_tween()
	coolTweens.tween_method(
					func(value): 
						$MenuCanvas/FadeRect.visible = true
						$MenuCanvas/FadeRect.self_modulate.a = value
						if value >= 1:
							GeneralUtils.loadScene("res://Gamestuffs/Game.tscn")
						,  
					0.0,  # Start value
					1.0,  # End value
					0.5    # Duration
				)
