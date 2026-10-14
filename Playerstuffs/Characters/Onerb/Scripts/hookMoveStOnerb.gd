extends PlayerStatePattern

func update():
	
	move_to_hook()
	Player.caudaEnd.global_position = Player.next_hook_position
	
	if Input.is_action_just_pressed("ctrl_2"):
		Player.getSpinny()
	
	next_to_hook()

func move_to_hook() -> void:
	# move essa porra
	var dir_vec: Vector2 = Player.hook_aim_direction.normalized()
	Player.motion = dir_vec * Player.hook_momentum
	
	# deixa o rabo preso la
	Player.caudaEnd.global_position = Player.next_hook_position

func next_to_hook() -> void:
	var distance_to_player = Player.global_position.distance_to(Player.caudaEnd.global_position)
	
	if distance_to_player < Player.hook_distance_gap:
		Player.change_state(Player.state_machine.st_air)

func exit_state():
	Player.return_hook_object()
