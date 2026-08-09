extends "res://Menustuffs/Submenu.gd"
class_name InputOptionsMenu

@export var boxWithABunchOfShitInIt:VBoxContainer

var coolOpts:Array = []
static var choosingKeybind:bool = false

func _ready() -> void:
	CoolMenu.blurAmount = 2
	CoolMenu.activeMusicLayers = 2
	
	$MenuCanvas/MidAnchor/PathLabel.text = tr("tab_opts") + " >> " + tr("keybinds")
	makeOptions()

#eu nao sei pqq eu tenho essa mania de fazer o codigo inteiro em ingles
#mesmo sabendo que o jogo inteiro vai ser em portugues
#fica mais facil pra mim sei la
func makeBind(coolId:int, internalName:String, visibleName:String):
	var newOpt = load("res://Menustuffs/OptionsMenu/KeybindThingie.tscn").instantiate()
	boxWithABunchOfShitInIt.add_child(newOpt)
	newOpt.makeIt(internalName, visibleName, coolId)
	coolOpts.append(newOpt)
	newOpt.connect('keyingBinds', func():
		InputOptionsMenu.choosingKeybind = true
		)
	newOpt.connect('noBinds', func():
		InputOptionsMenu.choosingKeybind = false
		)
	return newOpt

func makeOptions():
	var integer:int = 0
	for optione in OptionsUtils.bindList:
		var bind = makeBind(integer, optione[0], tr(optione[0]))
		integer += 1
	
	CoolMenu.maxSelected = integer
	CoolMenu.curSelected = 0

func _process(delta: float) -> void:
	for coolOpt in boxWithABunchOfShitInIt.get_children():
		if CoolMenu.curSelected != -1:
			coolOpt.selected = (coolOpt.id == CoolMenu.curSelected)
		else:
			coolOpt.selected = false
			
	if !InputOptionsMenu.choosingKeybind && coolOpts[CoolMenu.curSelected].selectCooldown <= 0:
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
			change_self_scene('res://Menustuffs/OptionsMenu/OptionsMenu.tscn')
