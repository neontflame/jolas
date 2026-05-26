extends "res://Playerstuffs/StateMachinery/airSt.gd"

func update():
	super()
	Player.can_activate_bubble()
	if Player.is_on_floor():
		Player.can_bubble_blast = true
