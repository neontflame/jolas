extends PlayerStatePattern

func enter_state():
	if Player.jumping:
		Player.jumping = false

func update():
	move_to_hook()
	Player.caudaEnd.global_position = Player.next_hook_position
	
	Player.plySprite.play("caudaPullback")
	
	if Input.is_action_just_pressed("ctrl_2"):
		Player.getSpinny()
	
	next_to_hook()

func move_to_hook() -> void:
	# move essa porra
	var dir_vec: Vector2 = Player.caudaEnd.global_position - Player.global_position
	Player.motion = dir_vec.normalized() * Player.hook_momentum
	
	# deixa o rabo preso la
	Player.caudaEnd.global_position = Player.next_hook_position

func next_to_hook() -> void:
	var distance_to_player = Player.global_position.distance_to(Player.caudaEnd.global_position)
	
	if distance_to_player < Player.hook_distance_gap:
		Player.change_state(Player.state_machine.st_air)

func exit_state():
	Player.return_hook_object()
	if Player.is_on_floor():
		Player.hooksTried = 0
