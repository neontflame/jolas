extends "res://Playerstuffs/StateMachinery/airSt.gd"
var isSpinkick := false
func enter_state():
	Player.plySprite.speed_scale = 1;
	Player.shakeForce = 0
	# print('Enter Air')
	if Player.jumping == true:
		Player.play_sfx('Jump', 10)
		if abs(Player.motion.x) > 800:
			Player.plySprite.play('vault')
		else:
			Player.plySprite.play('jump')
	
func update():
	super.update()
	if Player.is_on_floor():
		Player.delete_hitboxes()
		isSpinkick = false
	Player.shakeForce = lerp(Player.shakeForce, 0.0, 0.2)
	if PlayerUtils.is_jump_just_pressed() && !isSpinkick:
		isSpinkick = true
		Player.play_char_sfx('Spinkick', 'Sketcher')
		Player.plySprite.play('spinkick')
		Player.motion.y = -100
		Player.shakeForce = 2.0
		Player.make_hitbox(Vector2(7.0, 35.0),
							Vector2(5.79, 3.57),
							Player.ATTACK_DMG_LVL['spinkick'],
							300.0, 
							75.0)
		if Input.is_action_pressed("ctrl_left") \
		or not Input.is_action_pressed("ctrl_right") and Player.plySprite.flip_h:
			Player.plySprite.flip_h = true
			if Player.motion.x > -700:
				Player.motion.x = -900
			else:
				Player.motion.x += -150
		else:
			Player.plySprite.flip_h = false
			if Player.motion.x < 700:
				Player.motion.x = 900
			else:
				Player.motion.x += 150

func handleAnimations():
	if PlayerUtils.is_jump_just_pressed() && Player.jumpsDone < Player.JUMP_COUNT:
		Player.play_sfx('Jump', 10)
		if abs(Player.motion.x) > 800:
			Player.plySprite.play('vault')
		else:
			Player.plySprite.play('jump')
