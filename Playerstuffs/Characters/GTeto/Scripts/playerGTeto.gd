extends PlayerObject

var projForce := 0.0
var projCooldown := 0.0
var slamDunking:bool = false

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if (projCooldown > 0):
		projCooldown -= 1 * deltaOne
	
func handleHorizontalMovement() -> void:
	# Go my acceleratione.
	var ACCELERATION := 0.0
	var FRICTION := 0.0
	if is_on_floor():
		ACCELERATION = FLOOR_ACCELERATION
		FRICTION = FLOOR_FRICTION
		jumpsDone = 1
		jumping = false
	else:
		ACCELERATION = AIR_ACCELERATION
		FRICTION = AIR_FRICTION
		
	if (!movementEnabled):
		motion.x = motion.x * (FRICTION * deltaOne)
		return
		
	# walkfucks
	if Input.is_action_pressed("ctrl_left"):
		if (motion.x > -SOFT_MAX_SPEED * deltaOne):
			motion.x -= ACCELERATION * deltaOne
	elif Input.is_action_pressed("ctrl_right"):
		if (motion.x < SOFT_MAX_SPEED * deltaOne):
			motion.x += ACCELERATION * deltaOne
	else:
		motion.x = motion.x * (FRICTION * deltaOne)
