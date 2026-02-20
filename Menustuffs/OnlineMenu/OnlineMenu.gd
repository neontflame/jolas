extends "res://Menustuffs/Submenu.gd"
class_name OnlineMenu

var canControl:bool = true

func _ready() -> void:
	CoolMenu.blurAmount = 2
	CoolMenu.activeMusicLayers = 2
	
	print('Dude i hope')

func _enter_tree() -> void:	
	$MenuCanvas/MidAnchor/UsrTxt.text = GameUtils.username
	$MenuCanvas/MidAnchor/IPTxt.text = GameUtils.ipEntered
	$MenuCanvas/MidAnchor/PortTxt.text = str(GameUtils.portEntered)
	
	
	GPStats.is_multiplayer = true
	$MenuCanvas/MidAnchor/SaveBoxOnline.saveId = GPStats.saveNum
	$MenuCanvas/MidAnchor/SaveBoxOnline.renderSaveOnline()

func _process(delta: float) -> void:
	if !canControl: return
	
	if Input.is_action_just_pressed("ui_cancel"):
		CoolMenu.play_sfx('Back')
		CoolMenu.curSelected = 0
		GPStats.is_multiplayer = false
		change_self_scene('res://Menustuffs/MainMenu/MainMenu.tscn')
	
	GameUtils.username = $MenuCanvas/MidAnchor/UsrTxt.text
	GameUtils.ipEntered = $MenuCanvas/MidAnchor/IPTxt.text
	GameUtils.portEntered = int($MenuCanvas/MidAnchor/PortTxt.text)
	
	if $MenuCanvas/MidAnchor/UsrTxt.text != '' && $MenuCanvas/MidAnchor/IPTxt.text != '':
		var coisoInt = int($MenuCanvas/MidAnchor/PortTxt.text)
		if $MenuCanvas/MidAnchor/PortTxt.text == str(coisoInt):
			$MenuCanvas/MidAnchor/JoinButt.disabled = false
			$MenuCanvas/MidAnchor/HostButt.disabled = false
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
	CoolMenu.curSelected = GPStats.saveNum
	change_self_scene('res://Menustuffs/SaveMenu/SaveMenu.tscn')
	call_deferred('queue_free')


func on_host() -> void:
	GPStats.is_hosting = true
	goToGame()

func on_join() -> void:
	GPStats.is_hosting = false
	goToGame()

var mapToGoTo := ''

func goToGame():
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
							get_tree().change_scene_to_file("res://Gamestuffs/Game.tscn")
						,  
					0.0,  # Start value
					1.0,  # End value
					0.5    # Duration
				)
