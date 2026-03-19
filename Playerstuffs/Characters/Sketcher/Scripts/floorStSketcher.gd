extends "res://Playerstuffs/StateMachinery/floorSt.gd"

func handleAnimations() -> void:
	if Player.isSliding:
		Player.plySprite.play('slide')
	else:
		super.handleAnimations()
