extends Area2D
class_name CameraBound

@export var continuousX:bool = false
@export var continuousY:bool = false
@export var idealZoom:float = 1.0
# var otherCollidingCams = []
var letTheBodies:Array = []
# nos sequer precisamos dessa variavel ?
@onready var widthHeightWhatever := Vector2(
	$CollisionShape2D.shape.get_rect().size.x * 10 * scale.x,
	$CollisionShape2D.shape.get_rect().size.y * 10 * scale.y
)
@onready var bounds:Dictionary = {
	'width': widthHeightWhatever.x,
	'height': widthHeightWhatever.y,
	'x': global_position.x - (widthHeightWhatever.x/2),
	'y': global_position.y - (widthHeightWhatever.y/2)
}

@onready var continuousBounds:Dictionary = {
	'x': bounds.x,
	'y': bounds.y,
	'width': bounds.width,
	'height': bounds.height
}

func _on_area_entered(body: Area2D) -> void:
	if body is CameraBound:
		var continuousFurther:Vector2 = Vector2(
			continuousBounds.x + continuousBounds.width,
			continuousBounds.y + continuousBounds.height
		)
		
		var bodyFurther:Vector2 = Vector2(
			body.bounds.x + body.bounds.width,
			body.bounds.y + body.bounds.height
		)
		
		var min_x = min(continuousBounds.x, body.bounds.x)
		var min_y = min(continuousBounds.y, body.bounds.y)
		var max_x = max(continuousFurther.x, bodyFurther.x)
		var max_y = max(continuousFurther.y, bodyFurther.y)

		continuousBounds.x = min_x
		continuousBounds.y = min_y
		continuousBounds.width = max_x - min_x
		continuousBounds.height = max_y - min_y

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerObject:
		letTheBodies.append(body)

func _on_body_exited(body: Node2D) -> void:
	if letTheBodies.has(body):
		letTheBodies.erase(body)
	
func _physics_process(delta: float) -> void:
	for body in letTheBodies:
		body.idealZoom = idealZoom
		body.coolCamera.limit_left = bounds.x
		body.coolCamera.limit_right = bounds.x + bounds.width
		body.coolCamera.limit_top = bounds.y
		body.coolCamera.limit_bottom = bounds.y + bounds.height
		
		if continuousX:
			body.coolCamera.limit_left = continuousBounds.x
			body.coolCamera.limit_right = continuousBounds.x + continuousBounds.width
		if continuousY:
			body.coolCamera.limit_top = continuousBounds.y
			body.coolCamera.limit_bottom = continuousBounds.y + continuousBounds.height
