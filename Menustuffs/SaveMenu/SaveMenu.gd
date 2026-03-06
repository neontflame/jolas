extends "res://Menustuffs/Submenu.gd"

# var saveAmount:int = 6
var saveSlots:Array = []
var spaceBetweenSaves := 128.0
var isSelected:bool = false

@export var savesNode:Node2D

func _ready() -> void:
	CoolMenu.blurAmount = 2
	CoolMenu.activeMusicLayers = 2
	
	var coolNumberist:int = 0
	
	for kid in savesNode.get_children():
		if kid is SaveBox:
			kid.saveId = coolNumberist
			kid.renderSave()
			saveSlots.append(kid)
			coolNumberist += 1
	
	#for i in range(saveAmount):
		## print(i)
		#var coolioSave = load('res://Menustuffs/SaveMenu/SaveBox.tscn').instantiate()
		#coolioSave.saveId = i
		#coolioSave.position.y = spaceBetweenSaves * i
		#savesNode.add_child(coolioSave)
		#saveSlots.append(coolioSave)
		#coolioSave.renderSave()
	
	CoolMenu.maxSelected = coolNumberist

func _enter_tree() -> void:
	var coolTweens = create_tween()
	$MenuCanvas/FadeRect.self_modulate.a = 1.0
	$MenuCanvas/FadeRect.visible = true
	coolTweens.tween_method(
					func(value): 
						$MenuCanvas/FadeRect.self_modulate.a = value
						,  
					1.0,  # Start value
					0.0,  # End value
					0.3    # Duration
				)

func _process(delta: float) -> void:
	savesNode.position.x = lerp(	savesNode.position.x,
										-176 - (saveSlots[CoolMenu.curSelected].position.x * 0.1),
										0.2
									)
									
	savesNode.position.y = lerp(	savesNode.position.y,
										54 - (saveSlots[CoolMenu.curSelected].position.y * 0.75),
										0.2
									)

	savesNode.get_node('SetaCool').position.x = lerp(	savesNode.get_node('SetaCool').position.x,
										saveSlots[CoolMenu.curSelected].position.x - 42,
										0.5
									)
	savesNode.get_node('SetaCool').position.y = lerp(	savesNode.get_node('SetaCool').position.y,
										saveSlots[CoolMenu.curSelected].position.y + 56,
										0.5
									)
	if !isSelected:
		if Input.is_action_just_pressed("ui_up") || Input.is_action_just_pressed("ui_left"):
			CoolMenu.play_sfx('Tick')
			CoolMenu.curSelected = wrap(CoolMenu.curSelected - 1, 0, CoolMenu.maxSelected)
		if Input.is_action_just_pressed("ui_down") || Input.is_action_just_pressed("ui_right"):
			CoolMenu.play_sfx('Tick')
			CoolMenu.curSelected = wrap(CoolMenu.curSelected + 1, 0, CoolMenu.maxSelected)
		
		if Input.is_action_just_pressed("ui_accept"):
			CoolMenu.play_sfx('Go')
			GPStats.saveNum = CoolMenu.curSelected
			CoolMenu.curSelected = 0
			change_self_scene('res://Menustuffs/DipshitMenu/DipshitMenu.tscn')
			
		if Input.is_action_just_pressed("ui_delete"):
			SaveUtils.delete_save(CoolMenu.curSelected)
			saveSlots[CoolMenu.curSelected].renderSave()
			
		if Input.is_action_just_pressed("ui_cancel"):
			CoolMenu.play_sfx('Back')
			CoolMenu.curSelected = 0
			if GPStats.is_multiplayer:
				change_self_scene('res://Menustuffs/OnlineMenu/OnlineMenu.tscn')
			else:
				whiteTweenTo('res://Menustuffs/MainMenu/MainMenu.tscn')

func whiteTweenTo(scene:String):
	isSelected = true
	var coolTweens = create_tween()
	$MenuCanvas/FadeRect.self_modulate.a = 0.0
	$MenuCanvas/FadeRect.visible = true
	coolTweens.tween_method(
					func(value): 
						$MenuCanvas/FadeRect.self_modulate.a = value
						if value >= 1:
							change_self_scene(scene)
							Submenu.saveMenu.whiteTweenFrom()
						,  
					0.0,  # Start value
					1.0,  # End value
					0.3    # Duration
				)
