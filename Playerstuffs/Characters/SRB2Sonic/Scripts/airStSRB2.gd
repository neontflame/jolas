extends StatePattern

func enter_state():
	Player.make_hitbox(Vector2(0, 9), Vector2(2.2, 2.2), Player.ATTACK_DMG_LVL['default'], 50.0, 0.0, "spin_attack")
	
	Player.plySprite.speed_scale = max(abs(Player.motion.x) / Player.SOFT_MAX_SPEED, 0.25)
	Player.special_box.set_deferred("disabled", false)
	Player.player_collisions.set_deferred("disabled", true)
	Player.plySprite.offset = Vector2(0, 8)
	Player.shakeForce = 0
	if Player.jumping == true:
		Player.play_sfx('Jump', 10)
		Player.plySprite.play('jump')
	
func update():
	var axis = Input.get_axis("ctrl_left", "ctrl_right")
	
	Player.handlePhys()
	handleAnimations()
	Player.handleMovement()
	Player.handleCamera()
	
	if PlayerUtils.is_jump_just_pressed() and Player.canThok:
		Player.plySprite.speed_scale = 1.0
		Player.motion.y = 0.0
		Player.canThok = false
		if axis != 0.0:
			Player.motion.x = sign(axis) * 1400.0
		else:
			Player.motion.x = sign(Player.motion.x) * 1400.0
			
		if Player.motion.x > 0:
			Player.plySprite.flip_h = false
		else:
			Player.plySprite.flip_h = true
		Player.play_sfx("Thok")
	
	if Player.is_on_floor():
		Player.change_state(Player.state_machine.st_floor)

func exit_state():
	Player.special_box.set_deferred("disabled", true)
	Player.player_collisions.set_deferred("disabled", false)
	Player.plySprite.offset = Vector2(0, -4)
	Player.delete_hitboxes("spin_attack")

func handleAnimations():
	if PlayerUtils.is_jump_just_pressed() && Player.jumpsDone <= Player.JUMP_COUNT:
		Player.play_sfx('Jump', 10)
		Player.plySprite.play('jump')
