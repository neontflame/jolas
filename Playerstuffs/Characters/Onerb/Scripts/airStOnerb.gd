extends "res://Playerstuffs/StateMachinery/airSt.gd"

func enter_state():
	super.enter_state()

func update():
	super()
	
	Player.can_hook()
