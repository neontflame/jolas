extends "res://Playerstuffs/StateMachinery/hurtSt.gd"

func enter_state():
	super.enter_state()
	Player.plySprite.play('default')
	hurtTimer = 5.0
