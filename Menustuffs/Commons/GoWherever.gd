extends Node2D

func _ready() -> void:
	$ButtonLabel.visible = (OptionsUtils.preferences['buttonType'] != 5)
	$ButtonLabel.text = GeneralUtils.text_replacery($ButtonLabel.text)
