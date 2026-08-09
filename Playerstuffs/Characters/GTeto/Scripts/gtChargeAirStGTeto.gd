extends "res://Playerstuffs/Characters/GTeto/Scripts/gtChargeStGTeto.gd"

func enter_state():
	super.enter_state()
	yChange = 0.8
	projPos = Vector2(51.0, 43.0)

func update():
	super.update()
	if Player.projectileDodgit && not Player.chargeTween.is_running():
		Player.plySprite.play("gtSlam")
		
	if Player.is_on_floor():
		Player.change_state(Player.state_machine.st_charge_floor)

func chargeAnim():
	Player.plySprite.play("gtChargeAir")
	Player.plySprite.speed_scale = Player.projForce / Player.ATTACK_DMG_LVL["minProjectile"];

func shootAnim(strength:String):
	Player.plySprite.play("gtShootAir")

func recoil(strength:String):
	match (strength):
		'Strongest':
			if Input.is_action_pressed("ctrl_left") \
			or not Input.is_action_pressed("ctrl_right") and Player.plySprite.flip_h:
				Player.setMotion(500, -500, true, true)
			else:
				Player.setMotion(-500, -500, true, true)
		'Big':
			if Input.is_action_pressed("ctrl_left") \
			or not Input.is_action_pressed("ctrl_right") and Player.plySprite.flip_h:
				Player.setMotion(275, -275, true, true)
			else:
				Player.setMotion(-275, -275, true, true)
		_:
			pass
