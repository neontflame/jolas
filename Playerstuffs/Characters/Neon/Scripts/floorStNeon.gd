extends "res://Playerstuffs/StateMachinery/floorSt.gd"

func enter_state():
	super.enter_state()
	Player.base_camera_offset.x = 0
	
func update():
	super.update()
