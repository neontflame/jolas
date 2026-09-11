extends Node

@export var spritePica:Sprite2D

@export var coolColor:Color = Color.WHITE

func _ready() -> void:
	spritePica.self_modulate = coolColor
