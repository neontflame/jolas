extends Node2D

func set_text(text):
	$AnimationPlayer.play("default")
	if text is float or text is int:
		$Label.text = GeneralUtils.display_number(text)
		return
	$Label.text = str(text)
