extends StatePattern

func enter_state():
	Player.make_hitbox(Vector2(0, 9), Vector2(2.2, 2.2), Player.ATTACK_DMG_LVL['default'], 50.0, 0.0, "spin_attack")
	Player.play_sfx("Rolling", -10.0)
	Player.motion = Vector2(0.0, 4.0)
	Player.set_roll_collision(true)
	Player.generic_squish(false)
	Player.play_char_sfx("Spindash", "SRB2Sonic")
	Player.plySprite.play("spin_charge")
	Player.spinFxTimer.start()
	
func update():
	var delta = get_physics_process_delta_time()
	print(Player.spinCharge)
	Player.plySprite.speed_scale = max(0.25, Player.spinCharge / 2000.0)
	Player.spinCharge = move_toward(Player.spinCharge, 2000.0, 500.0 * delta)
	if Input.is_action_just_released("ctrl_2"):
		Player.motion.x = Player.spinCharge * (-1.0 if Player.plySprite.flip_h else 1.0)
		Player.change_state(Player.state_machine.st_roll)

func exit_state():
	Player.spinCharge = 1000.0
	Player.delete_hitboxes("spin_attack")
	Player.play_sfx("Release")
