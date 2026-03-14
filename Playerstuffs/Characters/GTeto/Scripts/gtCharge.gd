extends StatePattern
var yChange := 0.0
var projPos := Vector2(61.0, 7.0)

func update():
	Player.handlePhys()
	Player.handleCamera()
	if !Player.is_on_floor():
		Player.handleHorizontalMovement()
		
	if (Player.movementEnabled):
		if Input.is_action_pressed("ctrl_right"):
			Player.plySprite.flip_h = false;
			
		if Input.is_action_pressed("ctrl_left"):
			Player.plySprite.flip_h = true;
	
	if Input.is_action_pressed("ctrl_1"):
		chargeAnim()
		Player.projForce = lerp(Player.projForce, Player.ATTACK_DMG["maxProjectile"], 0.025)
		print(Player.projForce)
	if Input.is_action_just_released("ctrl_1"):
		shootAnim()
		Player.plySprite.speed_scale = 1;
		var dirMultiplier = (-1.0 if Player.plySprite.flip_h else 1.0)
		var coolDir = Vector2(dirMultiplier, yChange).rotated(Player.practicalAngle)
		var params:Dictionary = {
			"direction": coolDir,
			"speed": 15.0,
			"power": Player.projForce,
			"owner_id": Player.playerID
		}
		MapUtils.spawn_object('GProjectile', Player.position + Vector2(projPos.x * dirMultiplier, projPos.y), "Default", params)
		Player.projCooldown = 6.0 # so pra nao ficar spammy demais
		if Player.is_on_floor():
			Player.change_state(Player.state_machine.st_floor)
		else:
			Player.jumping = false
			Player.change_state(Player.state_machine.st_air)

func chargeAnim():
	pass

func shootAnim():
	pass
