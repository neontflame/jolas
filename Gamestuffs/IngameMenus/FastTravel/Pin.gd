extends Node2D
class_name MapaPin

@export var coolId = 0
@export var isRelevant:bool = true
@export var goto:Dictionary[String, String] = {
	'LEFT': '-1',
	'UP': '-1',
	'DOWN': '-1',
	'RIGHT': '-1'
}
@export var placeId:String = 'placeholder'

func _ready() -> void:
	if not GPStats.exploredMaps.has(placeId):
		queue_free()
	setRelevant(isRelevant)

func setRelevant(val:bool):
	if val:
		$AnimatedSprite2D.play('relevant')
	else:
		$AnimatedSprite2D.play('irrelevant')
