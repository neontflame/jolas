extends BossStatePattern

func enter_state():
	var current_frame = Boss.leSprite.get_frame()
	var current_progress = Boss.leSprite.get_frame_progress()
	Boss.leSprite.play('hurt')
	Boss.isHurting = true
	Boss.attack_timer.set_paused(true)
	await Boss.leSprite.animation_finished
	Boss.attack_timer.set_paused(false)
	Boss.change_state(Boss.state_machine.st_default)
	Boss.leSprite.set_frame_and_progress(current_frame, current_progress)

func update():
	Boss.handlePhys()
	Boss.handlePlyHits(false)
