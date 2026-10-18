extends PlayerStatePattern

func enter_state():
	# reseta a camera
	Player.base_camera_offset.x = 0
	
	# cria a hitbox
	create_hitbox()
	
	# animacao
	Player.plySprite.play('specialGo')
	
	# release sound
	Player.play_sfx('Release', 0)
	
	# setta o motion.x pro charge
	if Player.plySprite.flip_h:
		Player.motion.x = -Player.charge
	else:
		Player.motion.x = Player.charge
	
	# agora o y
	Player.motion.y = Player.charge * -0.25
	Player.motion.y += Player.charge * 0.45 * Input.get_vector("ctrl_left", "ctrl_right", "ctrl_up", "ctrl_down").y

func update():
	Player.handlePhys()
	
	if not Player.is_on_floor():
		Player.apply_player_gravity()
		if Player.is_on_wall():
			Player.change_state(Player.state_machine.wall_kick)
	else:
		Player.change_state(Player.state_machine.st_floor)

func exit_state():
	Player.jumping = false
	Player.delete_hitboxes('charge1')
	Player.delete_hitboxes('charge2')

func create_hitbox() -> void:
	Player.make_hitbox(Vector2(30.0, 8.0),
				Vector2(3.5, 2.75),
				Player.ATTACK_DMG_LVL['default'],
				250,
				-40,
				'charge1'
	)
	#TRAS
	Player.make_hitbox(Vector2(-30.0, 8.0),
				Vector2(3, 2),
				Player.ATTACK_DMG_LVL['default'] / 2,
				250,
				-40,
				'charge2'
	)
