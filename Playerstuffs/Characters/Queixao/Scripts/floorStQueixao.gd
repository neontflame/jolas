extends "res://Playerstuffs/StateMachinery/floorSt.gd"

func update():
	super.update()
	
	if Input.is_action_pressed("ctrl_2"):
		Player.fazerACoisa()
		Player.motion.x = (-2500 if Player.plySprite.flip_h else 2500)
	else:
		Player.delete_hitboxes('fodaespada')
		Player.delete_hitboxes('fodape')
		Player.delete_hitboxes('fodachifre1')
		Player.delete_hitboxes('fodachifre2')
