extends "res://Playerstuffs/StateMachinery/floorSt.gd"

func enter_state():
	super.enter_state()
	if !Player.slideTriggered.is_connected(onSlide):
		Player.slideTriggered.connect(onSlide)

func handleAnimations() -> void:
	if Player.isSliding:
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
