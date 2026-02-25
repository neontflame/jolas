extends PlayerObject

#region Sushi-specific
var ammo := 15
var rocketAngle := 0.0
var rocketPos := Vector2(0.0, 0.0)
var bhopCooldown := 10
@export var rocketIndicator:Sprite2D
#endregion

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	rocketIndicator.rotation = deg_to_rad(rocketAngle)
	
	if is_on_floor():
		if bhopCooldown > 0:
			bhopCooldown -= 1
