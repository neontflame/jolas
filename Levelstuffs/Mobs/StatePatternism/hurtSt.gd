extends MobStatePattern

var hurtTimer := 30.0;

func enter_state():
	print('Enter Hurt')
	Mob.leSprite.play('hurt')
	Mob.isHurting = true
	hurtTimer = 30.0
	
func update():
	hurtTimer -= 1; # i couldve used a timer for this but Nahhhhhhhhhhhhhhhhhh
	
	if hurtTimer <= 0:
		Mob.change_state(Mob.state_machine.st_default)
	
	Mob.handlePhys()
	Mob.handlePlyHits(false)
