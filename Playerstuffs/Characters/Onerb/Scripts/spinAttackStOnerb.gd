extends PlayerStatePattern

func enter_state():
	Player.plySprite.play("caudaSpin")
	var hits = Player.make_hitbox(Vector2.ZERO,
		Vector2(7, 7),
		Player.ATTACK_DMG_LVL['default'],
		50,
		-45,
		"speeeen"
	)
	hits.rotation_degrees = 45
	Player.plySprite.rotation_degrees = 0
	Player.caudaVision.visible = false
	Player.spriteRotatesByItself = true
	Player.play_char_sfx("ChickenSwing_Loop", "Onerb", 10.0, 1.5, ".ogg")

func update():
	# basic shits
	Player.handlePhys()
	Player.handleMovement()
	Player.apply_player_gravity()
	Player.handleCamera()
	Player.can_hook()
	
	# SPEEN
	Player.plySprite.rotation += (-45.0 if Player.plySprite.flip_h else 45.0) * Player.get_delta()
	
	# return to floor mf
	if Player.is_on_floor():
		Player.change_state(Player.state_machine.st_floor)

func exit_state():
	Player.delete_hitboxes("speeeen")
	Player.plySprite.rotation_degrees = 0.0
	Player.spriteRotatesByItself = false
	Player.stop_sfx()
