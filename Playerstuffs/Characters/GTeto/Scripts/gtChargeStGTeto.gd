extends StatePattern
var yChange := 0.0
var projPos := Vector2(61.0, 7.0)

var projThresholds:Dictionary = {}
var ITSGOING:bool = false

func enter_state():
	Player.play_char_sfx('Charge', 'GTeto')
	Player.sfx_player.seek((Player.projForce / 110))
		#Player.play_char_sfx('Charge', 'GTeto')
		#Player.chargeTween = get_tree().create_tween()
		#Player.chargeTween.tween_method(
			#func(v:float): 
			#Player.projForce = v
			#,
			#Player.ATTACK_DMG_LVL["minProjectile"],
			#Player.ATTACK_DMG_LVL["maxProjectile"], 
			#1.5 - Player.lastSec)

func update():
	Player.handlePhys()
	Player.handleCamera()
	if !Player.is_on_floor():
		Player.handleHorizontalMovement()
		
	if Player.movementEnabled and not Player.projectileDodgit:
		if Input.is_action_just_pressed("ctrl_up") \
		or Input.is_action_just_pressed("ctrl_right") \
		or Input.is_action_just_pressed("ctrl_down") \
		or Input.is_action_just_pressed("ctrl_left"):
			Player.chargeTween.stop()
			Player.stop_sfx()
			Player.projectileDodgit = true
			var speedsy:float = 300.0
			Player.setMotion(Input.get_axis("ctrl_left", "ctrl_right") * speedsy, Input.get_axis("ctrl_up", "ctrl_down") * speedsy, true, true)
			Player.invulnFrames = 24.0
			if Player.is_on_floor():
				Player.change_state(Player.state_machine.st_floor)
			else:
				Player.jumping = false
				Player.change_state(Player.state_machine.st_air)
	
		if Input.is_action_pressed("ctrl_right"):
			Player.plySprite.flip_h = false;
			
		if Input.is_action_pressed("ctrl_left"):
			Player.plySprite.flip_h = true;
	
	if Input.is_action_pressed("ctrl_1"):
		chargeAnim()
		print(Player.projForce)
		if Player.chargeTween.is_running(): 
			Player.lastSec = Player.chargeTween.get_total_elapsed_time()
			ITSGOING = (Player.lastSec >= 1.48)
			if ITSGOING:
				Player.play_char_sfx('ChargeMax', 'GTeto')
		# Player.projForce = lerp(Player.projForce, Player.ATTACK_DMG_LVL["maxProjectile"], 0.025)
	if Input.is_action_just_released("ctrl_1"):
		Player.jumping = false
		if Player.chargeTween:
			Player.chargeTween.stop()
		shootAnim(getThresholdCoiso()[0])
		print(getThresholdCoiso())
		recoil(getThresholdCoiso()[0])
		if getThresholdCoiso()[0] == 'Strongest':
			Player.play_char_sfx('ShootMax', 'GTeto')
		else:
			Player.play_char_sfx('Shoot', 'GTeto')
		Player.plySprite.speed_scale = 1;
		var dirMultiplier = (-1.0 if Player.plySprite.flip_h else 1.0)
		var coolDir = Vector2(dirMultiplier, yChange).rotated(Player.practicalAngle)
		var coolPos:Vector2 = Player.position + Vector2(projPos.x * dirMultiplier, projPos.y).rotated(Player.practicalAngle)
		var params:Dictionary = {
			"direction": coolDir,
			"speed": 15.0 * getThresholdCoiso()[1],
			"power": Player.projForce,
			"owner_id": Player.playerID
		}
		MapUtils.spawn_object('GProjectile', 
							coolPos, 
							getThresholdCoiso()[0], 
							params)
		Player.projCooldown = 6.0 # so pra nao ficar spammy demais
		Player.projForce = 0
		ITSGOING = false
		Player.lastSec = 0.0
		if Player.is_on_floor():
			Player.change_state(Player.state_machine.st_floor)
		else:
			Player.jumping = false
			Player.change_state(Player.state_machine.st_air)

func chargeAnim():
	pass

func shootAnim(strength:String):
	pass

func recoil(strength:String):
	pass

func getThresholdCoiso() -> Array:
	projThresholds = {
		"Strongest": [Player.ATTACK_DMG_LVL["minProjectile"] + (Player.ATTACK_DMG_LVL["maxProjectile"] / 1.75), 2.0],
		"Big": [Player.ATTACK_DMG_LVL["minProjectile"] + (Player.ATTACK_DMG_LVL["maxProjectile"] / 2.5), 1.5]
	}
	
	for coiso in projThresholds:
		if Player.projForce > projThresholds[coiso][0]:
			return [coiso, projThresholds[coiso][1]]
	return ["Default", 1.0]

func exit_state():
	if Player.chargeTween and Player.chargeTween.is_running():
		Player.lastSec = Player.chargeTween.get_total_elapsed_time()
