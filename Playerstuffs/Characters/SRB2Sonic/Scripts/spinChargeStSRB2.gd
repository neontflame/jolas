extends StatePattern

func enter_state():
	Player.make_hitbox(Vector2(0, 9), Vector2(2.2, 2.2), Player.ATTACK_DMG_LVL['default'], 50.0, 0.0, "spin_attack")
	Player.play_sfx("Rolling", -10.0)
func update():
	Player.motion = Vector2.ZERO
	
	if Input.is_action_just_released("ctrl_2"):
		Player.change_state(Player.state_machine.st_roll)
		Player.motion.x = 1000.0 * (-1.0 if Player.plySprite.flip_h else 1.0)

func exit_state():
	Player.delete_hitboxes("spin_attack")
	Player.play_sfx("Release", -10.0)
