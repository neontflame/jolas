extends "res://Playerstuffs/StateMachinery/floorSt.gd"

func update():
	super.update()
	
	if (Player.movementEnabled):
		if Input.is_action_just_pressed("ctrl_1") && Player.projCooldown <= 0:
			Player.projForce = Player.ATTACK_DMG["minProjectile"]
			Player.change_state(Player.state_machine.st_charge_floor)

func handleAnimations() -> void:
	if Player.is_on_floor():
		if Player.plySprite.animation == 'brake':
			Player.play_sfx('Skidding', 10)
			Player.shakeForce = Player.motion.x / 250
		else:
			Player.shakeForce = 0
			
		# primeira instancia de codigo com alma na godot ever
		if ((Input.is_action_pressed('ctrl_left') && Player.motion.x > 10) || (Input.is_action_pressed('ctrl_right') && Player.motion.x < 10)) && (Input.is_action_pressed('ctrl_left') != Input.is_action_pressed('ctrl_right')):
				if (Player.movementEnabled):
					Player.plySprite.play('brake')
		elif abs(Player.motion.x) > Player.FLOOR_ACCELERATION:
			Player.plySprite.speed_scale = abs(Player.motion.x) / 1000;
			if abs(Player.motion.x) > 800:
				Player.plySprite.play('run')
			else:
				Player.plySprite.play('walk')
		else:
			if Player.projCooldown <= 0 && Player.plySprite.animation != "gtShootFloor":
				Player.plySprite.play('default')
			Player.plySprite.speed_scale = 1;
		
	if (Player.movementEnabled):
		if Input.is_action_pressed("ctrl_right"):
			Player.plySprite.flip_h = false;
			
		if Input.is_action_pressed("ctrl_left"):
			Player.plySprite.flip_h = true;

func animDone():
	if Player.plySprite.animation == "gtShootFloor":
		Player.plySprite.play('default')
