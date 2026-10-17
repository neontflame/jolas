extends "res://Playerstuffs/StateMachinery/airSt.gd"

func enter_state():
	Player.plySprite.speed_scale = 1;
	Player.shakeForce = 0
	# print('Enter Air')
	if Player.jumping == true:
		Player.play_char_sfx("fpa_jump", "Onerb", 10.0, randf_range(0.8, 1.2))
		Player.plySprite.play('jump')

func update():
	super()
	
	Player.can_hook()
