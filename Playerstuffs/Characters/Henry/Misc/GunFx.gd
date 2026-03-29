extends Node2D

@export var theClip:Sprite2D
var velocity:Vector2 = Vector2(0,0)

func _ready() -> void:
	# print('hello')
	velocity = Vector2(
		randf_range(-2, 2),
		randf_range(-2, -10)
	)

func _physics_process(delta: float) -> void:
	var deltaOne = delta * 60
	
	theClip.position += velocity
	theClip.self_modulate.a -= 0.05 * deltaOne
	velocity.y += 1 * deltaOne
	
	if theClip.self_modulate.a <= 0.0:
		queue_free()
