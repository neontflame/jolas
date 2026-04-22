extends StatePattern

func enter_state():
	if Player.jumping:
		Player.generic_squish()
		Player.shakeForce = 0
		Player.plySprite.speed_scale = max(abs(Player.motion.x) / Player.SOFT_MAX_SPEED, 0.25)
		Player.set_roll_collision(true)
		Player.make_hitbox(Vector2(0, 9), Vector2(2.2, 2.2), Player.ATTACK_DMG_LVL['default'], 50.0, 0.0, "spin_attack")
		Player.plySprite.offset = Vector2(0, 8)
		Player.play_char_sfx("ClassicSonicJump", "SRB2Sonic")
		Player.plySprite.play('jump')
	
func update():
	var axis = Input.get_axis("ctrl_left", "ctrl_right")
	
	Player.handlePhys()
	handleAnimations()
	Player.handleMovement()
	Player.handleCamera()
	
	if Player.jumping:
		if PlayerUtils.is_jump_just_pressed() and Player.canThok:
			Player.plySprite.speed_scale = 1.0
			Player.motion.y = 0.0
			Player.canThok = false
			Player.generic_squish(false)
			if axis != 0.0:
				Player.motion.x = sign(axis) * 1400.0
			else:
				Player.motion.x = sign(Player.motion.x) * 1400.0
				
			if Player.motion.x > 0:
				Player.plySprite.flip_h = false
			else:
				Player.plySprite.flip_h = true
			Player.play_sfx("Thok", 5.0)
	
	if Player.is_on_floor():
		if Input.is_action_pressed("ctrl_2"):
			Player.change_state(Player.state_machine.st_roll)
			Player.play_sfx("Rolling", -10.0)
		else:
			Player.change_state(Player.state_machine.st_floor)

func exit_state():
	Player.set_roll_collision(false)
	Player.plySprite.offset = Vector2(0, -4)
	Player.delete_hitboxes("spin_attack")
	Player.canThok = true

func handleAnimations():
	if PlayerUtils.is_jump_just_pressed() && Player.jumpsDone <= Player.JUMP_COUNT:
		Player.play_sfx('Jump', 10)
		Player.plySprite.play('jump')
