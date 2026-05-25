@tool
extends Area2D
class_name LayerSwitcher

enum layers {
	Red_Layer,
	Blue_Layer
}

@export var switch_to: layers: ## Mude essa variável para mudar qual será a camada interativa com o Player. Evite usar isso com inimigos.
	set(v):
		switch_to = v
		change_object_color()
		
@export var visual_rect: ColorRect

func _ready() -> void:
	body_entered.connect(switch_layer)
	change_object_color()

func change_object_color():
	if switch_to == layers.Red_Layer:
		visual_rect.color = Color.RED
	else:
		visual_rect.color = Color.BLUE

func switch_layer(body: Node2D):
	if body is PlayerObject:
		print("oie")
		if switch_to == layers.Red_Layer:
			body.collision_mask = (1 << 0) | (1 << 2)
		else:
			body.collision_mask = (1 << 0) | (1 << 3)
