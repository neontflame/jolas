extends Node2D
class_name JolasLevel

@export var spawnpoint:Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MapUtils.set_map(self)
