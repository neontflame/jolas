extends "res://Menustuffs/Submenu.gd"

var curPath:String = 'user://'
var root:String = 'user://'
var curItems:Array = []

@export var boxWithABunchOfShitInIt:VBoxContainer

func _ready() -> void:
	CoolMenu.blurAmount = 2
	CoolMenu.activeMusicLayers = 2
	reload()
	pass

func reload():
	CoolMenu.curSelected = 0
	$MenuCanvas/MidAnchor/PathLabel.text = curPath
	curItems = ResourceLoader.list_directory(curPath)
	for file in DirAccess.get_files_at(curPath):
		curItems.append(file)
		
	print(curItems)
	if curPath != root:
		curItems.push_front('../')
	CoolMenu.maxSelected = len(curItems)
	
	for child in boxWithABunchOfShitInIt.get_children():
		boxWithABunchOfShitInIt.remove_child(child)
	
	var i:int = 0
	
	for item in curItems:
		var newFile = load("res://Menustuffs/AddonsMenu/FileThingie.tscn").instantiate()
		boxWithABunchOfShitInIt.add_child(newFile)
		newFile.filename = item
		newFile.setup()
		if GameUtils.loadedMods.has(curPath + newFile.filename):
			newFile.applied = true
		newFile.id = i
		i += 1

func _process(delta: float) -> void:
	for coolfile in boxWithABunchOfShitInIt.get_children():
		if CoolMenu.curSelected != -1:
			coolfile.selected = (coolfile.filename == curItems[CoolMenu.curSelected])
		else:
			coolfile.selected = false
		coolfile.applied = (GameUtils.loadedMods.has(curPath + coolfile.filename))
		
	if Input.is_action_just_pressed("ui_down"):
		CoolMenu.curSelected = wrap(CoolMenu.curSelected + 1, 0, CoolMenu.maxSelected)
		$MenuCanvas/MidAnchor/ScrollContainer.scroll_vertical = boxWithABunchOfShitInIt.get_children()[CoolMenu.curSelected].position.y
		CoolMenu.play_sfx('Tick')
	if Input.is_action_just_pressed("ui_up"):
		CoolMenu.curSelected = wrap(CoolMenu.curSelected - 1, 0, CoolMenu.maxSelected)
		$MenuCanvas/MidAnchor/ScrollContainer.scroll_vertical = boxWithABunchOfShitInIt.get_children()[CoolMenu.curSelected].position.y
		CoolMenu.play_sfx('Tick')
	if Input.is_action_just_pressed('ui_cancel'):
		goBack()
		
	if CoolMenu.curSelected != -1:
		if Input.is_action_just_pressed("ui_accept") || Input.is_action_just_pressed('ui_click'):
			if curItems[CoolMenu.curSelected] == '../':
				goBack()
			elif curItems[CoolMenu.curSelected].ends_with('/'):
				curPath += curItems[CoolMenu.curSelected]
				print(curPath)
				reload()
				CoolMenu.play_sfx('Tick')
			elif curItems[CoolMenu.curSelected].ends_with('.pck'):
				if !GameUtils.loadedMods.has(curPath + curItems[CoolMenu.curSelected]):
					ProjectSettings.load_resource_pack(curPath + curItems[CoolMenu.curSelected])
					GameUtils.loadedMods.append(curPath + curItems[CoolMenu.curSelected])
					CoolMenu.play_sfx('Go')

func goBack():
	CoolMenu.play_sfx('Back')
	if curPath == root:
		CoolMenu.curSelected = 0
		change_self_scene('res://Menustuffs/MainMenu/MainMenu.tscn')
	else:
		# e hora de voltar
		var lessPath:Array = curPath.split('/')
		lessPath.remove_at(-1)
		lessPath.remove_at(-1)
		print(lessPath)
		
		curPath = ''
		for lesser in lessPath:
			curPath += lesser
			curPath += '/'
			
		print(curPath)
		reload()
