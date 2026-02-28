extends MobStatePattern

var timerBeforeDeath := 60
var getOuttaHereTriggered := false

func enter_state():
	Mob.leSprite.play('dead')

func update():
	if timerBeforeDeath > 0:
		timerBeforeDeath -= 1
	if timerBeforeDeath <= 0 && !getOuttaHereTriggered:
		getOuttaHereTriggered = true
		getOuttaHere()
	Mob.handlePhys()

func getOuttaHere():
	var alphatween:Tween = create_tween()
	alphatween.tween_method(
		func(value):
			Mob.self_modulate.a = value
			if value <= 0.0:
				Mob.queue_free(),
			1.0, 0.0, 2.0)
