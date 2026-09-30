extends Submenu
@export var boxWithABunchOfShitInIt:VBoxContainer

var menuLayer = 0

func _ready() -> void:
	CoolMenu.blurAmount = 2
	CoolMenu.activeMusicLayers = 2
	reload()
	pass

func reload():
	CoolMenu.curSelected = 0
	menuLayer = 0
	
	var curItems = []
	for file in DirAccess.get_directories_at(ModUtils.get_mods_folder()):
		curItems.append(file)
	
	CoolMenu.maxSelected = len(curItems)
	
	for child in boxWithABunchOfShitInIt.get_children():
		boxWithABunchOfShitInIt.remove_child(child)
	
	var i:int = 0
	
	for item in curItems:
		var newFile = load("res://Menustuffs/Main/Addons/ModThingie.tscn").instantiate()
		boxWithABunchOfShitInIt.add_child(newFile)
		newFile.modId = item
		newFile.setup()
		if ModUtils.loadedMods.has(newFile.modId):
			newFile.applied = true
		newFile.id = i
		i += 1

func loadModInfo(mod:String):
	var modInfo:Dictionary = ModUtils.get_mod_info(mod)
	
	$MenuCanvas/MidAnchor/ModInfo/Icon.texture = ModUtils.get_mod_pic(mod)
	$MenuCanvas/MidAnchor/ModInfo/ModName.text = modInfo['name']
	$MenuCanvas/MidAnchor/ModInfo/ModAuthor.text = modInfo['author']
	$MenuCanvas/MidAnchor/ModInfo/RichTextLabel.text = modInfo['desc']
	
	menuLayer = 1
	$MenuCanvas/MidAnchor/ModInfo.visible = true

func loadMod(mod:String):
	if !ModUtils.loadedMods.has(mod):
		if ModUtils.is_mod_compatible(mod):
			if ModUtils.get_mod_info(mod)['restartsGame']:
				if not ModUtils.queuedMods.has(mod):
					ModUtils.queuedMods.append(mod)
			else:
				ProjectSettings.load_resource_pack(ModUtils.get_mod_path(mod))
				ModUtils.loadedMods.append(mod)
				# carregar scripts !!!
				# pra quem for maluco e fizer algum mod maluco que precise
				if len(ModUtils.get_mod_info(mod)['runOnLoad']) > 0:
					for modscript in ModUtils.get_mod_info(mod)['runOnLoad']:
						var script = load(modscript).new()
						get_tree().root.add_child(script)
			CoolMenu.play_sfx('Go')

func _physics_process(_delta: float) -> void:
	$MenuCanvas/MidAnchor/ModsList/ModLabel.text = tr_n('mod_loaded_single', 'mod_loaded_plural', len(ModUtils.loadedMods)) % len(ModUtils.loadedMods)
	if len(ModUtils.queuedMods) > 0:
		$MenuCanvas/MidAnchor/ModsList/ModLabel.text += tr_n('mod_queued_single', 'mod_queued_plural', len(ModUtils.queuedMods)) % len(ModUtils.queuedMods)
	
	for coolfile in boxWithABunchOfShitInIt.get_children():
		coolfile.canMouse = (menuLayer == 0)
		if CoolMenu.curSelected != -1:
			coolfile.selected = (coolfile.id == CoolMenu.curSelected)
		else:
			coolfile.selected = false
		coolfile.applied = (ModUtils.loadedMods.has(coolfile.modId) \
						or ModUtils.queuedMods.has(coolfile.modId))
	
	### ui actiones ###
	if menuLayer == 1: # MOD INFO MENU
		if not boxWithABunchOfShitInIt.get_children()[CoolMenu.curSelected].applied:
			$MenuCanvas/MidAnchor/ModInfo/PressEnter.text = 'Pressione ENTER pra carregar o mod!'
		else:
			$MenuCanvas/MidAnchor/ModInfo/PressEnter.text = 'Mod carregado!'
		
		if Input.is_action_pressed("ui_down"):
			$MenuCanvas/MidAnchor/ModInfo/RichTextLabel.get_v_scroll_bar().value += 2
		
		if Input.is_action_pressed("ui_up"):
			$MenuCanvas/MidAnchor/ModInfo/RichTextLabel.get_v_scroll_bar().value -= 2
		
		if Input.is_action_just_pressed('ui_cancel'):
			CoolMenu.play_sfx('Back')
			$MenuCanvas/MidAnchor/ModInfo.visible = false
			await get_tree().process_frame
			menuLayer = 0
		
		if CoolMenu.curSelected != -1:
			if Input.is_action_just_pressed("ui_accept"):
				loadMod(boxWithABunchOfShitInIt.get_children()[CoolMenu.curSelected].modId)
	
	elif menuLayer == 0: # MOD CHOICER MENU
		if len(boxWithABunchOfShitInIt.get_children()) > 0:
			if Input.is_action_just_pressed("ui_down"):
				CoolMenu.curSelected = wrap(CoolMenu.curSelected + 1, 0, CoolMenu.maxSelected)
				$MenuCanvas/MidAnchor/ModsList/ScrollContainer.scroll_vertical = boxWithABunchOfShitInIt.get_children()[CoolMenu.curSelected].position.y
				CoolMenu.play_sfx('Tick')
			
			if Input.is_action_just_pressed("ui_up"):
				CoolMenu.curSelected = wrap(CoolMenu.curSelected - 1, 0, CoolMenu.maxSelected)
				$MenuCanvas/MidAnchor/ModsList/ScrollContainer.scroll_vertical = boxWithABunchOfShitInIt.get_children()[CoolMenu.curSelected].position.y
				CoolMenu.play_sfx('Tick')
			
			if CoolMenu.curSelected != -1:
				if Input.is_action_just_pressed("ui_accept") \
				or Input.is_action_just_pressed('ui_click'):
					CoolMenu.play_sfx('Tick')
					loadModInfo(boxWithABunchOfShitInIt.get_children()[CoolMenu.curSelected].modId)
		
		if Input.is_action_just_pressed('ui_cancel'):
			CoolMenu.play_sfx('Back')
			if len(ModUtils.queuedMods) > 0:
				CoolMenu.curSelected = 0
				ModUtils.queuedMods.reverse()
				get_tree().change_scene_to_file('res://DontTouchstuffs/QueuedModLoader.tscn')
			else:
				CoolMenu.curSelected = 4
				change_self_scene('res://Menustuffs/MainMenu/MainMenu.tscn')
		
