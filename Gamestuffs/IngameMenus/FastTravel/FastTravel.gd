extends Submenu

@export var mapinha:LugarMapa
var canControl:bool = true

func _ready() -> void:
	CoolMenu.play_sfx('Unwrap')
	$AnimationPlayer.play('getIn')
	mapinha.changeMap(GameUtils.get_map_info(GPStats.curMap)['regionInternal'])

func _process(_delta: float) -> void:
	$MenuCanvas/LeftAnchor/Esc.visible = canControl
	if canControl:
		if Input.is_action_just_pressed("ui_cancel"):
			canControl = false
			CoolMenu.play_sfx('Wrap')
			$AnimationPlayer.play('getOut')
			await get_tree().create_timer(0.5).timeout
			change_self_scene('res://Gamestuffs/IngameMenus/Pause/Pause.tscn')

func goToThing(mapId:String):
	canControl = false
	CoolMenu.play_sfx('Wrap')
	$AnimationPlayer.play('getOut')
	await get_tree().create_timer(0.5).timeout
	
	JolasGame.instance.unpauseGame()
	JolasGame.instance.hud.questIcon.rerenderCtrl()
	GPStats.charObject.onUnpause()
	CoolMenu.instance.unmakeMenu()
	
	if mapId != GPStats.curMap:
		JolasGame.instance.fadeIn(0.5, 
		func(): 
			print('ok agora volta')
			JolasGame.instance.createLevel(mapId)
			JolasGame.instance.respawnPlayer(false, false)
			JolasGame.instance.fadeOut(0.5)
			)
