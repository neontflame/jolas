extends BossStatePattern

var timerBeforeDeath := 60
var getOuttaHereTriggered := false

func enter_state():
	Boss.leSprite.play('dead')
	Boss.attack_timer.stop()

func update():
	if timerBeforeDeath > 0:
		timerBeforeDeath -= 1
	if timerBeforeDeath <= 0 && !getOuttaHereTriggered:
		getOuttaHereTriggered = true
		getOuttaHere()
	Boss.handlePhys()
	Boss.inputSimulation(0,0)

func getOuttaHere():
	if GameUtils.get_map_info(GPStats.curMap).has('songFile'):
		JolasGame.instance.fadeBGM(1.0, GameUtils.get_map_info(GPStats.curMap)['songFile'])
	
	var alphatween:Tween = create_tween()
	alphatween.tween_method(
		func(value):
			Boss.leSprite.self_modulate.a = value
			if value <= 0.0:
				Boss.queue_free(),
			1.0, 0.0, 2.0)
