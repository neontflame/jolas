extends StatePattern

var hurtTimer := 30.0;

func enter_state():
	print('Enter Hurt')
	Player.plySprite.play('hurt')
	hurtTimer = 30.0
	
func update():
	Player.shakeForce = hurtTimer * 0.5
	hurtTimer -= 1; # i couldve used a timer for this but Nahhhhhhhhhhhhhhhhhh
	
	if hurtTimer <= 0:
		if Player.is_on_floor():
			Player.change_state(Player.state_machine.st_floor)
		else:
			Player.change_state(Player.state_machine.st_air)
	
	Player.handlePhys()
	# Player.handleMovement()
	Player.handleCamera()
