extends "res://Playerstuffs/StateMachinery/airSt.gd"

func enter_state():
	super.enter_state()

func update():
	super.update()

	if Player.motion.y > 0:
		Player.plySprite.play('fall')
	
	if Input.is_action_just_pressed("ctrl_2"):
		Player.change_state(Player.state_machine.st_rocket_air)
