extends "res://Playerstuffs/StateMachinery/airSt.gd"

func enter_state():
	if not Player.bubble_blasted:
		super()
		if Player.jumping:
			Player.make_hitbox(Vector2(0.0, 42.0),
				Vector2(3.0, 1.3),
				Player.ATTACK_DMG_LVL['default'],
				0.0,
				0.0,
				"jumpbox"
			)
		return
	Player.shakeForce = 0.0
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

func custom_espy_animation():
	Player.plySprite.rotation = Player.motion.angle()

func exit_state():
	super()
	Player.delete_hitboxes("jumpbox")
