extends "res://Playerstuffs/StateMachinery/airSt.gd"

func update():
	super.update()
	if Player.jumping:
		if Player.motion.y > 0:
			Player.plySprite.play("fall")
			
	if (Player.movementEnabled):
		if Input.is_action_just_pressed("ctrl_1") && Player.projCooldown <= 0:
			# Player.projForce = Player.ATTACK_DMG_LVL["minProjectile"]
			Player.change_state(Player.state_machine.st_charge_air)
			Player.play_char_sfx('Charge', 'GTeto')
			Player.chargeTween = get_tree().create_tween()
			Player.chargeTween.tween_method(
				func(v:float): 
				Player.projForce = v
				,
				(Player.ATTACK_DMG_LVL["minProjectile"] if Player.projForce == 0 else Player.projForce),
				Player.ATTACK_DMG_LVL["maxProjectile"], 
				1.5 - Player.lastSec)
		
	if Input.is_action_just_pressed("ctrl_2"):
		Player.change_state(Player.state_machine.st_slam)
