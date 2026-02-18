extends "res://Playerstuffs/StateMachinery/airSt.gd"

func update():
	if !Player.canDoCharge && !Player.isSpecialing:
		super.update();
		
	if Player.canDoCharge:
		Player.handlePhys()
		Player.handleMovement()
		Player.handleCamera()
		Player.camOffset.x = (-Player.charge if Player.plySprite.flip_h else Player.charge) / 10
		
		if Player.is_on_floor():
			Player.canDoCharge = false
			Player.change_state(Player.state_machine.st_floor)
		
	if !Player.isSpecialing && Player.movementEnabled:
		if Input.is_action_just_pressed("ctrl_2"):
			Player.canDoCharge = true
			Player.charge = 800
			Player.plySprite.play('specialCharge')
			
		if Input.is_action_pressed("ctrl_2") && Player.canDoCharge:
			Player.charge = lerp(Player.charge, 1920.0, 0.05)
			Player.shakeForce = Player.charge * 0.005
			# voce pode agora mudar de direçao no ar
			if Input.is_action_pressed("ctrl_left"):
				Player.plySprite.flip_h = true;
			if Input.is_action_pressed("ctrl_right"):
				Player.plySprite.flip_h = false;
				
		if Input.is_action_just_released("ctrl_2") && Player.canDoCharge:
			Player.shakeForce = 0
			Player.camOffset.x = 0
			Player.plySprite.play('specialGo')
			Player.play_sfx('Release', 0)
			if Player.plySprite.flip_h:
				Player.position.x += 1
				Player.motion.x = -Player.charge
			else:
				Player.position.x -= 1
				Player.motion.x = Player.charge
			
			Player.motion.y = -Player.charge * 0.45
			Player.canDoCharge = false
			Player.isSpecialing = true
			Player.jumping = false
			
	if Player.isSpecialing:
		Player.handlePhys()
		Player.handleCamera()
		
		if Player.is_on_wall():
			if Player.plySprite.flip_h:
				Player.motion.x = abs(Player.nonZeroXVel) * 0.325
			else:
				Player.motion.x = abs(Player.nonZeroXVel) * -0.325
				
			Player.motion.y = abs(Player.nonZeroXVel) * -0.35
			Player.isSpecialing = false
			Player.plySprite.play('specialBounceback')
			
		if Player.is_on_floor():
			Player.isSpecialing = false
			Player.change_state(Player.state_machine.st_floor)
