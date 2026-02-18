extends "res://Playerstuffs/StateMachinery/floorSt.gd"

func enter_state():
	super.enter_state()
	# bunnyhop
	if Player.bhopCooldown > 0:
		Player.motion.x *= 1.25
	else:
		Player.motion.x *= 1.125
		
	Player.bhopCooldown = floor(10 * Player.deltaOne) # 10 frames

func update():
	super.update()
	
	if Input.is_action_just_pressed("ctrl_2"):
		Player.change_state(Player.state_machine.st_rocket_floor)
