extends StatePattern

func enter_state():
	Player.fullInvuln = true
	Player.slamDunking = true
	Player.play_sfx('Release', 0)
	Player.plySprite.play("gtSlam")
	Player.motion.x = (-100 if Player.plySprite.flip_h else 100)
	Player.motion.y = 2400.0
	Player.plySprite.animation_finished.connect(animDone)
	Player.make_hitbox(Vector2(-3.0, -1.0), 
						Vector2(3.11, 5.715), 
						Player.ATTACK_DMG_LVL["slam"],
						30.0,
						135.0
						)

func update():
	Player.handlePhys()
	Player.handleCamera()
	if Player.slamDunking:
		Player.makeSlamParticle()
	
	Player.shakeForce = lerp(Player.shakeForce, 0.0, 0.1)
	if Player.is_on_floor() && Player.slamDunking:
		Player.slamDunking = false
		Player.delete_hitboxes()
		Player.motion.y = 4.0
		Player.motion.x = 0
		Player.shakeForce = 5
		Player.plySprite.play("gtSlamLand")
		
		var params:Dictionary = {
			"power": Player.ATTACK_DMG_LVL["slamLand"],
			"owner_id": Player.playerID
		}
		Player.play_sfx('Hit3', 0)
		MapUtils.spawn_object('GSlamFx', 
							Player.position, 
							"Default", 
							params)

func exit_state():
	if Player.plySprite.animation_finished.is_connected(animDone):
		Player.plySprite.animation_finished.disconnect(animDone)

func animDone():
	if Player.plySprite.animation == "gtSlamLand":
		if Input.is_action_pressed("ctrl_left") or Input.is_action_pressed("ctrl_right"):
			Player.play_sfx('Release', 0)
			for i in range(10):
				Player.makeSlamParticle()
			Player.make_hitbox_timed(0.5,
								Vector2(-3.0, -1.0), 
								Vector2(3.11, 4.715), 
								Player.ATTACK_DMG_LVL["slam"],
								1000.0,
								45.0
								)
			Player.motion.x = (-900 if Player.plySprite.flip_h else 900)
		Player.change_state(Player.state_machine.st_floor)
		Player.fullInvuln = false
