extends "res://Menustuffs/Submenu.gd"

var charPreview
var canControl:bool = true

func _ready() -> void:
	CoolMenu.blurAmount = 3
	CoolMenu.activeMusicLayers = 3
	CoolMenu.maxSelected = len(GameUtils.get_chars())
	changeSel(0)
	
func _process(delta: float) -> void:
	$MenuCanvas/MidAnchor/IconSelect/Icons.position.x = lerp(
		$MenuCanvas/MidAnchor/IconSelect/Icons.position.x,
		0.0,
		0.2
	)
	
	if !canControl: return ############################ ui coisos
	
	if Input.is_action_just_pressed("ui_cancel"):
		CoolMenu.play_sfx('Back')
		change_self_scene('res://Menustuffs/SaveMenu/SaveMenu.tscn')
		CoolMenu.curSelected = GPStats.saveNum
	
	if Input.is_action_just_pressed("ui_left"):
		CoolMenu.play_sfx('Tick')
		changeSel(-1)
	if Input.is_action_just_pressed("ui_right"):
		CoolMenu.play_sfx('Tick')
		changeSel(1)
	if Input.is_action_just_pressed("ui_accept"):
		if GPStats.is_multiplayer:
			CoolMenu.play_sfx('Go')
			GPStats.char = GameUtils.get_chars()[CoolMenu.curSelected]
			print(GPStats.char)
			CoolMenu.curSelected = GPStats.saveNum
			change_self_scene('res://Menustuffs/OnlineMenu/OnlineMenu.tscn')
		else:
			getEmBoy()

func changeSel(amount:int):
	$MenuCanvas/MidAnchor/IconSelect/Icons.position.x += 104 * amount
	
	CoolMenu.curSelected = wrap(CoolMenu.curSelected + amount, 0, CoolMenu.maxSelected)
	
	var nextIcon = wrap(CoolMenu.curSelected + 1, 0, CoolMenu.maxSelected)
	var prevIcon = wrap(CoolMenu.curSelected - 1, 0, CoolMenu.maxSelected)
	
	$MenuCanvas/MidAnchor/IconSelect/Icons/CurIcon.texture = GameUtils.get_char_asset(GameUtils.get_chars()[CoolMenu.curSelected], 'Icon.png')
	$MenuCanvas/MidAnchor/IconSelect/Icons/IconRight.texture = GameUtils.get_char_asset(GameUtils.get_chars()[nextIcon], 'Icon.png')
	$MenuCanvas/MidAnchor/IconSelect/Icons/IconLeft.texture = GameUtils.get_char_asset(GameUtils.get_chars()[prevIcon], 'Icon.png')
	
	loadCharPreview(GameUtils.get_chars()[CoolMenu.curSelected])
	
func loadCharPreview(char:String):
	if charPreview != null: charPreview.queue_free()
	
	if GameUtils.get_char_preview(char) != null:
		charPreview = GameUtils.get_char_preview(char).instantiate()
		charPreview.position = $MenuCanvas/MidAnchor/CharInfo/PreviewPos.position
		$MenuCanvas/MidAnchor/CharInfo.add_child(charPreview)
	
	$MenuCanvas/MidAnchor/CharInfo/Name.text = GameUtils.get_char_info(char)['name']
	$MenuCanvas/MidAnchor/CharInfo/Desc.text = GameUtils.get_char_info(char)['desc'] + '\n' + GameUtils.get_char_info(char)['ability']

var mapToGoTo := ''

func getEmBoy() -> void:
	CoolMenu.activeMusicLayers = 0
	CoolMenu.play_sfx('Go')
	canControl = false
	GPStats.char = GameUtils.get_chars()[CoolMenu.curSelected]
	# aqui e o mapa default
	# favor trocar quando tiver um mapa de verdade!
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
