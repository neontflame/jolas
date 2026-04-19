extends "res://Menustuffs/Submenu.gd"

@export var checkestMark:Sprite2D

var checkPositiones:Array[Vector2] = [
	Vector2(-87.0, -39.0),
	Vector2(-85.0, 12.0),
	Vector2(-83.0, 53.0),
	Vector2(-80.0, 98.0),
]

var optssss:Array[StringName] = [
	"resume",
	"fasttravel",
	"options",
	"exit"
]

var canControl:bool = true

func _ready() -> void:
	print("para com essa porra")
	CoolMenu.curSelected = 0
	CoolMenu.maxSelected = len(optssss)
	CoolMenu.play_sfx('Unwrap')
	$AnimationPlayer.play('newThing')
	$MenuCanvas/Control/SaveBox.renderPaused()
	await get_tree().create_timer(0.01).timeout
	selectry(0)

func _process(_delta: float) -> void:
	if canControl:
		if Input.is_action_just_pressed("ui_down"):
			selectry(1)
		if Input.is_action_just_pressed("ui_up"):
			selectry(-1)
		if Input.is_action_just_pressed("ui_cancel"):
			doSomething("resume")
		if Input.is_action_just_pressed("ui_accept"):
			doSomething(optssss[CoolMenu.curSelected])

func selectry(selAmount:int):
	#print('test')
	CoolMenu.curSelected = wrap(CoolMenu.curSelected + selAmount, 0, CoolMenu.maxSelected)
	if selAmount != 0: CoolMenu.play_sfx('Tick')
	checkestMark.position = checkPositiones[CoolMenu.curSelected]

func doSomething(opt:StringName):
	CoolMenu.play_sfx('Go')
	canControl = false
	
	match opt:
		'resume':
			JolasGame.instance.unpauseGame()
			JolasGame.instance.hud.questIcon.rerenderCtrl()
			GPStats.charObject.onUnpause()
			# CoolMenu.instance.tweenOut()
			CoolMenu.play_sfx('Wrap')
			$AnimationPlayer.play('getOut')
			await get_tree().create_timer(0.5).timeout
			CoolMenu.instance.unmakeMenu()
		'fasttravel':
			CoolMenu.play_sfx('Wrap')
			$AnimationPlayer.play('getOut')
			await get_tree().create_timer(0.5).timeout
			change_self_scene('res://Gamestuffs/IngameMenus/FastTravel/FastTravel.tscn')
		'options':
			CoolMenu.play_sfx('Wrap')
			$AnimationPlayer.play('getOut')
			await get_tree().create_timer(0.5).timeout
			change_self_scene('res://Menustuffs/OptionsMenu/OptionsMenu.tscn')
		'exit':
			SaveUtils.save_game(GPStats.saveNum)
			for hudchild in JolasGame.instance.hud.get_children(true):
				hudchild.visible = false
			CoolMenu.play_sfx('Wrap')
			$AnimationPlayer.play('getOut')
			if GPStats.is_multiplayer:
				CoolMenu.curSelected = 1
				MultiplayerMayhem.remove_multiplayer_peer()
			else:
				CoolMenu.curSelected = 0
			JolasGame.instance.fadeIn(1.0, func():
				get_tree().change_scene_to_file("res://Menustuffs/Menu.tscn")
				)
				
		_:
			canControl = true
			CoolMenu.stop_sfx('Go')
			CoolMenu.play_sfx('Back')
			print('nao implementei ainda :X')
