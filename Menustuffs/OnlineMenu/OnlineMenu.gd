extends "res://Menustuffs/Submenu.gd"
class_name OnlineMenu

var canControl:bool = true

func _ready() -> void:
	CoolMenu.blurAmount = 2
	CoolMenu.activeMusicLayers = 2

func _enter_tree() -> void:	
	$MenuCanvas/MidAnchor/UsrTxt.text = SaveUtils.get_online_info()['name']
	$MenuCanvas/MidAnchor/IPTxt.text = SaveUtils.get_online_info()['ip']
	$MenuCanvas/MidAnchor/PortTxt.text = str(int(SaveUtils.get_online_info()['port']))
	$MenuCanvas/MidAnchor/SrvNameTxt.text = SaveUtils.get_online_info()['serverName']
	
	if !GPStats.is_multiplayer:
		GPStats.saveSlot = SaveUtils.get_online_info()['saveSlot']
		GPStats.char = SaveUtils.get_online_info()['char']
	
	$MenuCanvas/MidAnchor/SaveBoxOnline.saveId = GPStats.saveSlot
	$MenuCanvas/MidAnchor/SaveBoxOnline.renderSaveOnline()
	
	GPStats.is_multiplayer = true

func _process(delta: float) -> void:
	if !canControl: return
	
	if Input.is_action_just_pressed("ui_cancel"):
		CoolMenu.play_sfx('Back')
		CoolMenu.curSelected = 1
		GPStats.is_multiplayer = false
		SaveUtils.save_online()
		change_self_scene('res://Menustuffs/MainMenu/MainMenu.tscn')
	
	$MenuCanvas/MidAnchor/SrvNameTxt.placeholder_text = "Servidor de " + $MenuCanvas/MidAnchor/UsrTxt.text
	
	OnlineUtils.username = $MenuCanvas/MidAnchor/UsrTxt.text
	OnlineUtils.ipEntered = $MenuCanvas/MidAnchor/IPTxt.text
	OnlineUtils.portEntered = int($MenuCanvas/MidAnchor/PortTxt.text)
	OnlineUtils.serverName = $MenuCanvas/MidAnchor/SrvNameTxt.text
	
	MultiplayerMayhem.player_info["name"] = OnlineUtils.username
	
	if $MenuCanvas/MidAnchor/UsrTxt.text != '' && $MenuCanvas/MidAnchor/IPTxt.text != '':
		var coisoInt = int($MenuCanvas/MidAnchor/PortTxt.text)
		if $MenuCanvas/MidAnchor/PortTxt.text == str(coisoInt):
			$MenuCanvas/MidAnchor/JoinButt.disabled = !(coisoInt == clampi(coisoInt, 1024, 65535))
			$MenuCanvas/MidAnchor/HostButt.disabled = !(coisoInt == clampi(coisoInt, 1024, 65535))
		else:
			$MenuCanvas/MidAnchor/JoinButt.disabled = true
			$MenuCanvas/MidAnchor/HostButt.disabled = true
	else:
		$MenuCanvas/MidAnchor/JoinButt.disabled = true
		$MenuCanvas/MidAnchor/HostButt.disabled = true

func _on_usrtxt_text_changed() -> void:
	CoolMenu.play_sfx('Tick')

func savebox_click() -> void:
	CoolMenu.play_sfx('Go')
	SaveUtils.save_online()
	CoolMenu.curSelected = GPStats.saveSlot
	change_self_scene('res://Menustuffs/SaveMenu/SaveMenu.tscn')
	call_deferred('queue_free')


func on_host() -> void:
	GPStats.is_hosting = true
	goToGame()

func on_join() -> void:
	GPStats.is_hosting = false
	# goToGame()
	testConnect()

func on_serverlist() -> void:
	CoolMenu.curSelected = 0
	SaveUtils.save_online()
	CoolMenu.play_sfx('Go')
	change_self_scene('res://Menustuffs/OnlineMenu/OnlineServersMenu/OnlineServersMenu.tscn')

func testConnect():
	AttemptConnMenu.prevMenu = "OnlineMenu"
	change_self_scene('res://Menustuffs/OnlineMenu/AttemptConnMenu.tscn')

var mapToGoTo := ''

func goToGame():
	canControl = false
	CoolMenu.activeMusicLayers = 0
	CoolMenu.play_sfx('Go')
	SaveUtils.save_online()
	
	if SaveUtils.get_save_info(GPStats.saveSlot)['new'] == true:
		mapToGoTo = GameUtils.defaultMap
	else:
		mapToGoTo = SaveUtils.get_save_info(GPStats.saveSlot)['map']
		
	GPStats.load_info_from_save(GPStats.saveSlot)
	
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
