extends "res://Levelstuffs/Bosses/StatePatternism/defaultSt.gd"

func enter_state() -> void:
	match Boss.current_attack_state:
		Boss.attack_state.NONE:
			Boss.leSprite.play('default')
			if Boss.attack_timer.is_stopped():
				Boss.attack_timer.start(3.0)
		Boss.attack_state.THROW:
			Boss.leSprite.play('clickThrow')
			if Boss.attack_timer.is_stopped():
				Boss.attack_timer.start(3.0)
		Boss.attack_state.SANDLER_WAVE:
			Boss.leSprite.play('clickStart')
			if Boss.attack_timer.is_stopped():
				Boss.attack_timer.start(3.0)
		Boss.attack_state.SANDLER_REVERT:
			Boss.leSprite.play('clickClick')
			if Boss.attack_timer.is_stopped():
				Boss.attack_timer.start(3.0)

func update():
	super.update()
