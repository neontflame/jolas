extends "res://Playerstuffs/StateMachinery/airSt.gd"

func enter_state():
	if not Player.bubble_blasted:
		super()
		return
	Player.plySprite.play("bubbleLaunch")

func update():
	Player.handlePhys()
	Player.handleMovement()
	Player.handleCamera()
	Player.apply_player_gravity()
	
	if Player.bubble_blasted:
		custom_espy_animation()
	else:
		handleAnimations()
	
	if Player.is_on_floor():
		if Player.bubble_blasted:
			Player.delete_hitboxes("bubble")
			Player.plySprite.rotation = 0.0
		Player.change_state(Player.state_machine.st_floor)
		
	Player.can_activate_bubble()
	if Player.is_on_floor():
		Player.can_bubble_blast = true
		Player.bubble_blasted = false

func custom_espy_animation():
	Player.plySprite.rotation = Player.motion.angle()
