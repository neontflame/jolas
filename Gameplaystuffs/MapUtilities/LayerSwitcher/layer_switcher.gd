@tool
extends Area2D
class_name LayerSwitcher

enum layers {
	Red_Judas,
	Blue_Judas
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
	if switch_to == layers.Red_Judas:
		visual_rect.color = Color.RED
	else:
		visual_rect.color = Color.BLUE

func switch_layer(body: Node2D):
	if body is PlayerObject or body is MobObject:
		if switch_to == layers.Red_Judas:
			body.collision_mask = (1 << 0) | (1 << 2)
		else:
			body.collision_mask = (1 << 0) | (1 << 3)
