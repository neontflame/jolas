extends StatePattern

func enter_state():
	Player.plySprite.play('jump')
	Player.special_box.set_deferred("disabled", false)
	Player.player_collisions.set_deferred("disabled", true)
	Player.plySprite.offset = Vector2(0, 8)
	Player.make_hitbox(Vector2(0, 9), Vector2(2.2, 2.2), Player.ATTACK_DMG_LVL['default'], 50.0, 0.0, "spin_attack")
	Player.walkingEnabled = false

func update():
	Player.handlePhys()
	Player.handleMovement()
	Player.handleCamera()
	
	Player.plySprite.speed_scale = max(abs(Player.motion.x) / Player.SOFT_MAX_SPEED, 0.25)
	
	if PlayerUtils.is_jump_just_pressed() and (Player.is_on_floor() or (Player.jumpsDone <= (Player.JUMP_COUNT))):
		Player.change_state(Player.state_machine.st_air)
	
	if abs(Player.motion.x) < 50.0:
		Player.change_state(Player.state_machine.st_floor)
	
	if not Player.is_on_floor():
		Player.change_state(Player.state_machine.st_air)
func exit_state():
	Player.special_box.set_deferred("disabled", true)
	Player.player_collisions.set_deferred("disabled", false)
	Player.plySprite.offset = Vector2(0, -4)
	Player.delete_hitboxes("spin_attack")
	Player.walkingEnabled = true
