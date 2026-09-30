extends "res://Playerstuffs/StateMachinery/airSt.gd"

var theAim:Vector2 = Vector2.ZERO

func enter_state():
	super.enter_state()

func update():
	if Player.is_on_floor():
		Player.change_state(Player.state_machine.st_floor)
		
	if Player.hooking == Player.HookStatus.UNHOOKED:
		Player.handlePhys()
		Player.handleCamera()
		if Player.isGonnaHook:
			Player.apply_player_gravity(Player.GRAVITY / 2)
			acquireTarget()
			Player.caudaRaycast.rotation = theAim.angle()
			Player.plySprite.play("caudaPrepare")
		if not Player.isGonnaHook:
			handleAnimations()
			Player.handleMovement()
			Player.apply_player_gravity()
		
		if Input.is_action_just_pressed("ctrl_2") && !Player.spinny:
			if Player.hooksTried < Player.hookChances:
				Player.isGonnaHook = true
		
		if Input.is_action_just_released("ctrl_2"):
			if Player.isGonnaHook:
				Player.hookOnto(theAim)
	else:
		if Input.is_action_just_pressed("ctrl_2") and Player.canSpinny:
			Player.getSpinny()

func acquireTarget():
	var input = Input.get_vector("ctrl_left", "ctrl_right", "ctrl_up", "ctrl_down")
	if input != Vector2.ZERO:
		theAim = input
