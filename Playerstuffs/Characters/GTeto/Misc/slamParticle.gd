extends Node2D

func _ready() -> void:
	$AnimatedSprite2D.play("Fx" + str(randi_range(1, 3)))
	var coolTweenie = create_tween()
	coolTweenie.tween_method(doYouWantTheMethod, 1.0, 0.001, 0.4)

func doYouWantTheMethod(a):
	$AnimatedSprite2D.self_modulate.a = a
	
	if a <= 0.0:
		queue_free()

func delete_hitboxes_actual(hitboxId:String):
	pass
