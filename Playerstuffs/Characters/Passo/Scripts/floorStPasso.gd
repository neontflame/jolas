extends "res://Playerstuffs/StateMachinery/floorSt.gd"

func enter_state():
	super.enter_state()
	if Player.reboundQueued and (not Player.rebounding):
		Player.reboundQueued = false
		Player.rebounding = true
		Player.plySprite.play('reboundFloor')
		Player.stunFrames = 6.0
		while Player.stunFrames > 0:
			await get_tree().process_frame
		Player.motion.x = Player.motion.x * 1.025
		Player.motion.y = abs(Player.lastInterestingYv) * -1.2
		print(Player.rebounding)

func handleAnimations() -> void:
	if not Player.rebounding:
		super.handleAnimations()
