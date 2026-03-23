extends Node2D

func _ready() -> void:
	reparent(get_parent().get_parent().get_parent())

func _on_animation_finished() -> void:
	queue_free()
