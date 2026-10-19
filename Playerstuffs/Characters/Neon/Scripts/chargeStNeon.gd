extends PlayerStatePattern

var legacyBehavior:bool = true

func enter_state():
	Player.charge = 800
	Player.plySprite.play('specialCharge')

func update():
	Player.handleCameraSpecial()
	Player.apply_player_gravity(10.0)
	
	if legacyBehavior:
		Player.handleMovement()
		Player.handlePhys()
		if Player.is_on_floor():
			Player.change_state(Player.state_machine.st_floor)
	
	charge_control()
	
	# animations
	# shakin
	if Player.current_state == self:
		Player.shakeForce = Player.charge * 0.005

func exit_state():
	Player.shakeForce = 0

func charge_control() -> void:
	# desacelera pelo lerp se tiver subindo
	if Player.motion.y < 0.0:
		Player.motion.y = lerp(Player.motion.y, 0.0, 0.05)
	
	# guarda a carga
	Player.charge = lerp(Player.charge, 1920.0, 0.05)
	
	# escolha sua direcao
	if Input.is_action_pressed("ctrl_right"):
		Player.plySprite.flip_h = false
	if Input.is_action_pressed("ctrl_left"):
		Player.plySprite.flip_h = true
	
	# tire o charge!! go go go!!!
	if not Input.is_action_pressed("ctrl_2"):
		Player.change_state(Player.state_machine.release)
