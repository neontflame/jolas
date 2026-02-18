extends StatePattern

func enter_state():
	Player.plySprite.speed_scale = 1;
	Player.shakeForce = 0
	# print('Enter Air')
	if Player.jumping == true:
		Player.play_sfx('Jump', 10)
		Player.plySprite.play('jump')
	
func update():
	Player.handlePhys()
	Player.handleMovement()
	Player.handleCamera()
		
	if Player.is_on_floor():
		Player.change_state(Player.state_machine.st_floor)
