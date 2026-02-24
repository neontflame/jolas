extends "res://Menustuffs/Submenu.gd"

@export var boxWithABunchOfShitInIt:VBoxContainer

var coolOpts:Array = []

func _ready() -> void:
	CoolMenu.blurAmount = 2
	CoolMenu.activeMusicLayers = 2
	
	makeOptions()

#eu nao sei pqq eu tenho essa mania de fazer o codigo inteiro em ingles
#mesmo sabendo que o jogo inteiro vai ser em portugues
#fica mais facil pra mim sei la
func makeOption(coolId:int, internalName:String, visibleName:String, optionery:Array, defValue:Variant):
	var newOpt = load("res://Menustuffs/OptionsMenu/OptThingie.tscn").instantiate()
	boxWithABunchOfShitInIt.add_child(newOpt)
	newOpt.makeIt(internalName, visibleName, coolId, optionery, defValue)
	coolOpts.append(newOpt)
	newOpt.connect('goToOptions', goToOptions)
	return newOpt

func makeOptions():
	var integer:int = 0
	for optione in OptionsUtils.coolOptiones:
		var opt = makeOption(integer, optione[0], optione[1], optione[2], optione[3])
		if (opt.validOpts != []):
			integer += 1
	
	CoolMenu.maxSelected = integer
	CoolMenu.curSelected = 0

func _process(delta: float) -> void:
	for coolOpt in boxWithABunchOfShitInIt.get_children():
		if CoolMenu.curSelected != -1:
			coolOpt.selected = (coolOpt.id == CoolMenu.curSelected)
		else:
			coolOpt.selected = false
			
	if Input.is_action_just_pressed("ui_down"):
		CoolMenu.curSelected = wrap(CoolMenu.curSelected + 1, 0, CoolMenu.maxSelected)
		$MenuCanvas/MidAnchor/ScrollContainer.scroll_vertical = boxWithABunchOfShitInIt.get_children()[CoolMenu.curSelected].position.y
		CoolMenu.play_sfx('Tick')
	if Input.is_action_just_pressed("ui_up"):
		CoolMenu.curSelected = wrap(CoolMenu.curSelected - 1, 0, CoolMenu.maxSelected)
		$MenuCanvas/MidAnchor/ScrollContainer.scroll_vertical = boxWithABunchOfShitInIt.get_children()[CoolMenu.curSelected].position.y
		CoolMenu.play_sfx('Tick')
	if Input.is_action_just_pressed('ui_cancel'):
		print(OptionsUtils.preferences)
		OptionsUtils.save_prefs()
		CoolMenu.play_sfx('Back')
		CoolMenu.curSelected = 2
		change_self_scene('res://Menustuffs/MainMenu/MainMenu.tscn')
		
	"""if CoolMenu.curSelected != -1:
		if Input.is_action_just_pressed("ui_accept") || Input.is_action_just_pressed('ui_click'):
			if (coolOpts[CoolMenu.curSelected].validOpts != ['slider']):
				coolOpts[CoolMenu.curSelected].changeThing(1)"""

func goToOptions():
	OptionsUtils.save_prefs()
	CoolMenu.play_sfx('Go')
	CoolMenu.curSelected = 0
	change_self_scene('res://Menustuffs/OptionsMenu/InputOptionsMenu.tscn')
