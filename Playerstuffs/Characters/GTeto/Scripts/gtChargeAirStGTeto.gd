extends "res://Playerstuffs/Characters/GTeto/Scripts/gtChargeStGTeto.gd"

func enter_state():
	yChange = 0.8
	projPos = Vector2(51.0, 43.0)

func update():
	super.update()
	
	if Player.is_on_floor():
		Player.change_state(Player.state_machine.st_charge_floor)

func chargeAnim():
	Player.plySprite.play("gtChargeAir")
	Player.plySprite.speed_scale = Player.projForce / Player.ATTACK_DMG["minProjectile"];

func shootAnim():
	Player.plySprite.play("gtShootAir")
