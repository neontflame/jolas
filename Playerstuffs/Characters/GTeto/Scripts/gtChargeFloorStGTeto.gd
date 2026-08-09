extends "res://Playerstuffs/Characters/GTeto/Scripts/gtChargeStGTeto.gd"

func enter_state():
	super.enter_state()
	yChange = 0.0
	Player.motion.y = 4
	projPos = Vector2(61.0, 7.0)

func update():
	super.update()
	Player.motion.x = Player.motion.x * Player.FLOOR_FRICTION
	
	if not Player.is_on_floor():
		Player.change_state(Player.state_machine.st_charge_air)
		
func chargeAnim():
	Player.plySprite.play("gtChargeFloor")
	Player.plySprite.speed_scale = Player.projForce / Player.ATTACK_DMG_LVL["minProjectile"];

func shootAnim(strength:String):
	match strength:
		'Strongest':
			Player.plySprite.play("gtShootMax")
		_:
			Player.plySprite.play("gtShootFloor")

func recoil(strength:String):
	match (strength):
		'Strongest':
			if Input.is_action_pressed("ctrl_left") \
			or not Input.is_action_pressed("ctrl_right") and Player.plySprite.flip_h:
				Player.setMotion(500, 0, true, false)
			else:
				Player.setMotion(-500, 0, true, false)
			await get_tree().create_timer(0.01).timeout
			Player.motion.y = -300
			await get_tree().create_timer(0.01).timeout
			Player.plySprite.play("gtShootMax")
		'Big':
			if Input.is_action_pressed("ctrl_left") \
			or not Input.is_action_pressed("ctrl_right") and Player.plySprite.flip_h:
				Player.setMotion(250, 0, true, true)
			else:
				Player.setMotion(-250, 0, true, true)
		_:
			pass
