extends "res://Playerstuffs/StateMachinery/floorSt.gd"

func enter_state():
	# print('Enter Floor')
	pass

func update():
	Player.handleScriptCagadoDoScratch()
	Player.handleCamera()
	Player.animMaster()
	
	if Input.is_action_just_pressed("ctrl_2"):
		fazSoco()

func fazSoco():
	Player.soco = true
	Player.make_hitbox(	Vector2(29.0, -5.0),
								Vector2(1.9, 1.0),
								Player.ATTACK_DMG_LVL['default'],
								250,
								-15
			)
	await get_tree().create_timer(0.2).timeout
	Player.delete_hitboxes()
	Player.soco = false
