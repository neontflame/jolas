extends Node2D

func _process(delta: float) -> void:
	$Parallax2D6/Clouds1.transform.y.x = $Parallax2D6.screen_offset.x / 1000
