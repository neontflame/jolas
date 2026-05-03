extends Node2D

func set_text(text):
	$AnimationPlayer.play("default")
	$Label.text = GeneralUtils.display_number(text)
