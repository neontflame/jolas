extends StatePattern

func enter_state():
	Player.canThok = true
	Player.motion.y = 4
	if not Player.plySprite.animation_finished.is_connected(animDone):
		Player.plySprite.animation_finished.connect(animDone)
	pass

func update():
	Player.handlePhys()
	Player.handleMovement()
	Player.handleCamera()
	handleAnimations()
	
	if not Player.is_on_floor():
		Player.change_state(Player.state_machine.st_air)
	
	if Input.is_action_pressed("ctrl_2"):
		if abs(Player.motion.x) > 100.0:
			Player.change_state(Player.state_machine.st_roll)
			Player.play_sfx("Rolling", -10.0)
		else:
			Player.change_state(Player.state_machine.st_spin_charge)
	
func handleAnimations() -> void:
	if Player.is_on_floor():
		if Player.plySprite.animation == 'brake':
			Player.play_sfx('Skidding', 10)
			Player.shakeForce = Player.motion.x / 250
		else:
			Player.shakeForce = 0
			
		# primeira instancia de codigo com alma na godot ever
		if ((Input.is_action_pressed('ctrl_left') && Player.motion.x > 10) \
		or (Input.is_action_pressed('ctrl_right') && Player.motion.x < 10)) \
		and (Input.is_action_pressed('ctrl_left') != Input.is_action_pressed('ctrl_right')):
				if (Player.movementEnabled && Player.walkingEnabled):
					Player.plySprite.play('brake')
		elif abs(Player.motion.x) > Player.FLOOR_ACCELERATION:
			Player.plySprite.speed_scale = abs(Player.motion.x) / 1000;
			if abs(Player.motion.x) > 800:
				Player.plySprite.play('run')
			else:
				Player.plySprite.play('walk')
		else:
			Player.plySprite.play('default')
			Player.plySprite.speed_scale = 1;
		
	if (Player.movementEnabled && Player.walkingEnabled):
		if Input.is_action_pressed("ctrl_right"):
			Player.plySprite.flip_h = false;
			
		if Input.is_action_pressed("ctrl_left"):
			Player.plySprite.flip_h = true;

func animDone():
	pass
