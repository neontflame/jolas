extends PlayerStatePattern

func enter_state():
	# sprites
	Player.plySprite.play("caudaPrepare")
	
	Player.targetSpr.visible = true
	
	# direcao default caso o player nao esteja mexendo porra nenhuma
	if Player.get_player_vector() == Vector2.ZERO:
		Player.hook_aim_direction = Player.motion.normalized()

func update():
	# fire hook
	Player.caudaEnd.global_position = Player.global_position
	Player.release_hook()
	
	# slow fall
	Player.apply_player_gravity(Player.GRAVITY / 8.0)
	
	# hook aim setups
	if Player.get_player_vector() != Vector2.ZERO:
		Player.hook_aim_direction = Player.get_player_vector()
		Player.caudaRaycast.rotation = Player.hook_aim_direction.angle()
		
		# sprite flip
		if sign(Player.get_player_vector().x) < 0.0:
			Player.plySprite.flip_h = true
		else:
			Player.plySprite.flip_h = false
	Player.handle_hook_aim()
	
	# camera
	Player.handleCameraSpecial(Player.hook_aim_direction)

func exit_state():
	Player.targetSpr.visible = false
