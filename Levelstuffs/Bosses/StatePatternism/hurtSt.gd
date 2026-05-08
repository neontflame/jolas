extends BossStatePattern

var hurtTimer := 30.0;

func enter_state():
	print('Enter Hurt')
	Boss.leSprite.play('hurt')
	Boss.isHurting = true
	hurtTimer = 30.0
	
func update():
	hurtTimer -= 1; # i couldve used a timer for this but Nahhhhhhhhhhhhhhhhhh
	
	if hurtTimer <= 0:
		Boss.change_state(Boss.state_machine.st_default)
	
	Boss.handlePhys()
	Boss.handlePlyHits(false)
