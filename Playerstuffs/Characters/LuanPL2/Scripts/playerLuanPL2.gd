extends PlayerObject
var soco := false

func handleScriptCagadoDoScratch() -> void:
	var multMotion = 1.125
	# HABEMUS
	motion.y += 0.5 * multMotion
	if Input.is_action_pressed("ctrl_right") && movementEnabled:
		plySprite.flip_h = false
		motion.x += 0.7 * multMotion
	if Input.is_action_pressed("ctrl_left") && movementEnabled:
		plySprite.flip_h = true
		motion.x += -0.7 * multMotion
		# switch_costume_to()
	motion.x = motion.x * 0.9
	position.x += motion.x
	if is_on_floor():
		position.y -= 1.0
		if is_on_floor():
			position.y -= 1.0
			if is_on_floor():
				position.y -= 1.0
				if is_on_floor():
					position.y -= 1.0
					if is_on_floor():
						position.y -= 1.0
	if is_on_wall():
		position.x += motion.x * -1.0
		position.x += -1.0
		position.y -= -5.0
		position.x += 1.0
		if Input.is_action_pressed("ctrl_up") && movementEnabled:
			if motion.x > 0:
				motion.x = -8 * multMotion
			else:
				motion.x = 8 * multMotion
			motion.y = -10 * multMotion
		else:
			motion.x = 0
	position.y += motion.y
	if is_on_floor():
		position.y += motion.y
		motion.y = 0
	position.y -= -1.0
	if is_on_floor():
		if Input.is_action_pressed("ctrl_up") && movementEnabled:
			motion.y = -10 * multMotion
	position.y -= 1.0
	
	# Not Physix but we ball
	plySprite.position.x = randf_range(-shakeForce, shakeForce)
	plySprite.position.y = randf_range(-shakeForce, shakeForce)

func general_collision():
	return is_on_floor() || is_on_wall() || is_on_ceiling()

func animMaster():
	if soco:
		plySprite.play("punch")
	else:
		plySprite.play("default")

func yeowch(hpLost:float, fromBehind:bool = false, vel:Vector2 = Vector2(250, -250)):
	vel = vel * 0.025
	super.yeowch(hpLost, fromBehind, vel)
