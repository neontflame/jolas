extends "res://Playerstuffs/StateMachinery/floorSt.gd"

func handleAnimations() -> void:
	if not Player.plySprite.animation.begins_with('useItem'):
		super.handleAnimations()
	else:
		Player.plySprite.speed_scale = 1;
		if (Player.movementEnabled):
			if Input.is_action_pressed("ctrl_right"):
				Player.plySprite.flip_h = false;
				
			if Input.is_action_pressed("ctrl_left"):
				Player.plySprite.flip_h = true;

func animDone():
	if Player.plySprite.animation.begins_with('useItem'):
		Player.plySprite.play('default')
