extends PlayerObject

var gunCooldowns:Array[float] = [0.0, 0.0] #i want you to meet my daughters GUN NUMBER 1 AND GUN NUMBER 2
@export var GUN_SPEED_ADD = 50.0

func _process(delta: float) -> void:
	for coold in range(len(gunCooldowns)):
		if gunCooldowns[coold] > 0.0:
			gunCooldowns[coold] -= deltaOne

func shootEm(gunber:int):
	jumping = false
	if gunCooldowns[gunber ] > 0.0: return
	gunCooldowns[gunber] = 3.0
	
	play_char_sfx('Pistol', 'Henry', -2)
	plySprite.play('gun' + str(gunber + 1))
	make_hitbox_timed(0.05, Vector2(423.0, 18.0),
	Vector2(36.455, 0.435),
	ATTACK_DMG_LVL['default'],
	1000, 335, 'gun')
	
	motion.y -= 50
	if Input.is_action_pressed("ctrl_left") \
	or not Input.is_action_pressed("ctrl_right") and plySprite.flip_h:
		if motion.x > GUN_SPEED_ADD:
			motion.x += GUN_SPEED_ADD * 1.25
		else:
			motion.x += GUN_SPEED_ADD
	else:
		if motion.x < -GUN_SPEED_ADD:
			motion.x -= GUN_SPEED_ADD * 1.25
		else:
			motion.x -= GUN_SPEED_ADD

func handleMovement():
	super.handleMovement()
	if movementEnabled:
		if Input.is_action_just_pressed("ctrl_2"):
			shootEm(0)
			makeGunClip(0)
		if Input.is_action_just_pressed("ctrl_1"):
			shootEm(1)
			makeGunClip(1)

func makeGunClip(gunber:int):
	var gunPos:Array[Vector2] = [
		Vector2(44.0, 14.0),
		Vector2(60.0, 11.0)
	]
	var thingie = GameUtils.get_char_asset("Henry", "Misc/GunFx.tscn").instantiate()
	get_parent().add_child(thingie)
	thingie.position = position + Vector2(gunPos[gunber].x * (-1 if plySprite.flip_h else 1), gunPos[gunber].y)

func on_jump(jumpNum:int):
	if jumpNum > 2:
		var thingie = GameUtils.get_char_asset("Henry", "Misc/JumpFx.tscn").instantiate()
		plySprite.add_child(thingie)
