extends PlayerStatePattern

var is_missed: bool = false

func enter_state():
	Player.plySprite.play("caudaThrow")
	
	Player.motion = Vector2.ZERO
	
	Player.cauda_tip_collision.set_deferred("disabled", false)
	
	is_missed = false

func update():
	var distance_to_player = Player.global_position.distance_to(Player.caudaEnd.global_position)
	if not is_missed:
		Player.move_hook_object()
		if distance_to_player >= Player.max_hook_distance - 12.0:
			is_missed = true
	else:
		Player.force_hook_cancel()
		Player.motion = Player.last_motion
		if not Player.is_on_floor():
			Player.change_state(Player.state_machine.st_air)
		else:
			Player.change_state(Player.state_machine.st_floor)
			Player.hooksTried = 0
	
	# just get spinny whatever brujh
	if Input.is_action_just_pressed("ctrl_2"):
		Player.getSpinny()
