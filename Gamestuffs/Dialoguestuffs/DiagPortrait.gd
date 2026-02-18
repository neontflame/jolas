extends Node2D
class_name DiagPortrait

@onready var ptrt = $AnimatedSprite2D
var intendedPos := Vector2(0, 0)

func _process(delta:float) -> void:
	if intendedPos != Vector2(0,0):
		position.x = lerp(position.x, intendedPos.x, 0.2)
		position.y = lerp(position.y, intendedPos.y, 0.2)
		
	pass
