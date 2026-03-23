extends "res://Playerstuffs/StateMachinery/airSt.gd"

func update():
	super.update()
	if Player.jumping:
		if Player.motion.y > 0:
			Player.plySprite.play("fall")
