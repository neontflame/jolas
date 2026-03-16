extends "res://Playerstuffs/Characters/GTeto/Scripts/gtChargeStGTeto.gd"

func enter_state():
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

func shootAnim():
	Player.plySprite.play("gtShootFloor")
