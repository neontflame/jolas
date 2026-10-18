extends "res://Playerstuffs/Characters/Neon/Scripts/airStNeon.gd"

var wall_kick: Vector2 = Vector2(400.0, 400.0)

func enter_state():
	Player.plySprite.speed_scale = 1
	Player.shakeForce = 0
	Player.plySprite.play('specialBounceback')
	
	if Player.plySprite.flip_h:
		Player.motion.x = wall_kick.x
	else:
		Player.motion.x = -wall_kick.x
	
	Player.motion.y = -wall_kick.y
	
	Player.play_sfx("InstaShield")

func update():
	super()
	if Player.is_on_floor():
		Player.delete_hitboxes()
		Player.invulnFrames = 4
