extends "res://Playerstuffs/StateMachinery/airSt.gd"

func enter_state():
	Player.plySprite.speed_scale = 1
	Player.shakeForce = 0
	# print('Enter Air')
	await get_tree().process_frame
	
	if Player.jumping == true:
		Player.play_sfx('Jump', 10)
	Player.plySprite.play('jump')

func update():
	super.update()
		
	if Input.is_action_pressed("ctrl_2"):
		Player.change_state(Player.state_machine.charge)
