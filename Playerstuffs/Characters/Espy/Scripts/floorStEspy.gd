extends "res://Playerstuffs/StateMachinery/floorSt.gd"

func enter_state():
	Player.can_bubble_blast = true
	Player.bubble_blasted = false
	Player.motion.y = 1.0

func update():
	super()
	Player.can_activate_bubble()
