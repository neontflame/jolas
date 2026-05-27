extends "res://Playerstuffs/StateMachinery/floorSt.gd"

func enter_state():
	Player.can_bubble_blast = true
	Player.bubble_blasted = false
	Player.motion.y = 1.0
	Player.JUMP_COUNT = 1

func update():
	Player.handlePhys()
	if Input.is_action_pressed("ctrl_1"):
		Player.handleMovement(30.0, 30.0, 800.0)
	else:
		Player.handleMovement()
		if abs(Player.motion.x) > Player.SOFT_MAX_SPEED:
			Player.motion.x = lerp(Player.motion.x, Player.SOFT_MAX_SPEED * sign(Player.motion.x), 0.05)
	Player.handleCamera()
	handleAnimations()
	
	if not Player.is_on_floor():
		Player.change_state(Player.state_machine.st_air)
	Player.can_activate_bubble()
