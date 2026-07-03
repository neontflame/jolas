extends "res://Playerstuffs/StateMachinery/floorSt.gd"

func enter_state():
	super.enter_state()
	if !Player.slideTriggered.is_connected(onSlide):
		Player.slideTriggered.connect(onSlide)

func update():
	if not Player.isBoosting or sign(Player.motion.x) == sign(Player.slopeAdd):
		Player.handleMovement()
	Player.handlePhys()
	Player.handleCamera()
	handleAnimations()
	
	if not Player.is_on_floor():
		Player.change_state(Player.state_machine.st_air)

func handleAnimations() -> void:
	if Player.isSliding:
		if Player.plySprite.animation != 'slide':
			Player.plySprite.play('slide')
	else:
		Player.delete_hitboxes('slide')
		super.handleAnimations()

func onSlide():
	Player.make_hitbox(	Vector2(30.0, 34.0), 
						Vector2(4.96, 3.09), 
						Player.ATTACK_DMG_LVL['slide'], 
						400, 
						285.0, 
						'slide')

func exit_state():
	if Player.slideTriggered.is_connected(onSlide):
		Player.slideTriggered.disconnect(onSlide)
