extends Node2D

var blurTween:Tween
@export var blurBGFx:TextureRect
var menucools:Node2D
var theVolModifier:float = 0

func _ready() -> void:
	CoolMenu.instance = self
	CoolMenu.curMenu = 'Ingame'

func makeMenu(menu:StringName):
	tweenIn()
	JolasGame.instance.isMenu = true
	theVolModifier = -10
	if menucools: menucools.free()
	menucools = load("res://Gamestuffs/IngameMenus/%s/%s.tscn" % [menu, menu]).instantiate()
	add_child(menucools)

func unmakeMenu():
	theVolModifier = 0
	JolasGame.instance.bgmStream.volume_db = GeneralUtils.get_volume_db('bgm', theVolModifier)
	if menucools != null: menucools.queue_free()
	JolasGame.instance.isMenu = false
	tweenOut()

func tweenIn():
	if blurTween != null: blurTween.kill()
	blurTween = create_tween()
	blurTween.tween_method(
		func(value): blurBGFx.material.set_shader_parameter("amount", value),  
		0.0,  # Start value
		2.75,  # End value
		0.5     # Duration
	)

func tweenOut():
	if blurTween != null: blurTween.kill()
	blurTween = create_tween()
	blurTween.tween_method(
		func(value): blurBGFx.material.set_shader_parameter("amount", value),  
		2.75,  # Start value
		0.0,  # End value
		0.5     # Duration
	)

func _process(delta: float) -> void:
	if JolasGame.instance.isMenu: 
		JolasGame.instance.bgmStream.volume_db = GeneralUtils.get_volume_db('bgm', theVolModifier)
