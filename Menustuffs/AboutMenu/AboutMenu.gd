extends Submenu

func _ready() -> void:
	CoolMenu.blurAmount = 2
	CoolMenu.activeMusicLayers = 3
	var cool = $MenuCanvas/MidAnchor/ScrollContainer/VBoxContainer/RichTextLabel6
	cool.text = cool.text.replace('coolVer', GameUtils.gameVersion)

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		if Input.is_action_pressed("ui_accept"):
			$MenuCanvas/MidAnchor/ScrollContainer.scroll_vertical -= 2
		$MenuCanvas/MidAnchor/ScrollContainer.scroll_vertical -= 2
	if Input.is_action_pressed("ui_down"):
		if Input.is_action_pressed("ui_accept"):
			$MenuCanvas/MidAnchor/ScrollContainer.scroll_vertical += 2
		$MenuCanvas/MidAnchor/ScrollContainer.scroll_vertical += 2
	if Input.is_action_just_pressed('ui_cancel'):
		CoolMenu.play_sfx('Back')
		CoolMenu.curSelected = 3
		change_self_scene('res://Menustuffs/MainMenu/MainMenu.tscn')
