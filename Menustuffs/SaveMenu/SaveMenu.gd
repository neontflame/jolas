extends "res://Menustuffs/Submenu.gd"

var saveAmount:int = 6
var saveSlots:Array = []

@export var savesNode:Node2D

func _ready() -> void:
	CoolMenu.blurAmount = 2
	CoolMenu.activeMusicLayers = 2
	
	for i in range(saveAmount):
		print(i)
		var coolioSave = load('res://Menustuffs/SaveMenu/SaveBox.tscn').instantiate()
		coolioSave.saveId = i
		coolioSave.position.y = 128.0 * i
		savesNode.add_child(coolioSave)
		saveSlots.append(coolioSave)
		coolioSave.renderSave()
	
	CoolMenu.maxSelected = saveAmount

func _process(delta: float) -> void:
	savesNode.position.y = lerp(	savesNode.position.y,
										(CoolMenu.curSelected * -72.0) + 54,
										0.2
									)
									
	savesNode.get_node('SetaCool').position.y = lerp(	savesNode.get_node('SetaCool').position.y,
										(CoolMenu.curSelected * 128.0) + 36,
										0.5
									)
	if Input.is_action_just_pressed("ui_up"):
		CoolMenu.play_sfx('Tick')
		CoolMenu.curSelected = wrap(CoolMenu.curSelected - 1, 0, CoolMenu.maxSelected)
	if Input.is_action_just_pressed("ui_down"):
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
		change_self_scene('res://Menustuffs/MainMenu/MainMenu.tscn')
