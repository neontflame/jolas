extends BossObject
class_name BigSandler

@export var FUCKING_aura: AnimatedSprite2D

func awake():
	JolasGame.instance.fadeBGM()
	FUCKING_aura.visible = true
	await get_tree().create_timer(2).timeout
	JolasGame.instance.playBGM(CUSTOM_BOSS_MUSIC if CUSTOM_BOSS_MUSIC != "" else "ULTRAKILLCybergrind.ogg")
	FUCKING_aura.play('default')
	await get_tree().create_timer(4.22).timeout
	MapUtils.map.removeEdgy()
	healthBar.visible = true
	FUCKING_aura.visible = false
	$AnimatedSprite2D.visible = true
	change_state(state_machine.st_default)
