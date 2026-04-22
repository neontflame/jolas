extends Sprite2D

func _ready() -> void:
	scale = Vector2(1.2, 0.8)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.5)

func _on_timer_timeout() -> void:
	queue_free()
