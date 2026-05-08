extends BossObject

func awake():
	JolasGame.instance.fadeBGM()
	$FuckingAura.visible = true
	await get_tree().create_timer(2).timeout
	JolasGame.instance.playBGM(CUSTOM_BOSS_MUSIC if CUSTOM_BOSS_MUSIC != "" else "ULTRAKILLCybergrind.ogg")
	$FuckingAura.play('default')
	await get_tree().create_timer(4.22).timeout
	MapUtils.map.removeEdgy()
	healthBar.visible = true
	$FuckingAura.visible = false
	$AnimatedSprite2D.visible = true
	change_state(state_machine.st_default)
