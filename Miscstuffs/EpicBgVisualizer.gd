extends Node2D

func _physics_process(delta: float) -> void:
	$Camera2D.position.x += 1
