extends "res://Playerstuffs/StateMachinery/airSt.gd"

func update():
	super.update()
	if Player.jumping:
		if Player.motion.y > 0:
			Player.plySprite.play("fall")
			
	if (Player.movementEnabled):
		if Input.is_action_just_pressed("ctrl_1") && Player.projCooldown <= 0:
			Player.projForce = Player.ATTACK_DMG["minProjectile"]
			Player.change_state(Player.state_machine.st_charge_air)
		
	if Input.is_action_just_pressed("ctrl_2"):
		#todo: gtslam
		pass
