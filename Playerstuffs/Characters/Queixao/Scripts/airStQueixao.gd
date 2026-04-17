extends "res://Playerstuffs/StateMachinery/airSt.gd"

func update():
	super.update()
	
	if Input.is_action_pressed("ctrl_2"):
		Player.fazerACoisa()
	else:
		Player.delete_hitboxes('fodaespada')
		Player.delete_hitboxes('fodape')
		Player.delete_hitboxes('fodachifre1')
		Player.delete_hitboxes('fodachifre2')
