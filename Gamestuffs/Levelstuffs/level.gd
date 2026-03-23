extends Node2D
class_name JolasLevel

@export var spawnpoint:Node2D
@export var spawnpointBack:Node2D

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	MapUtils.set_map(self)
