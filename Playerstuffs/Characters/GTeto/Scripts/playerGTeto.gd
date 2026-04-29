extends PlayerObject

var projForce := 0.0
var projCooldown := 0.0
var slamDunking:bool = false
var previousPos:Vector2 = Vector2(0, 0)
var posDifference:Vector2 = Vector2(0, 0)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if (projCooldown > 0):
		projCooldown -= 1 * deltaOne
	if previousPos != position:
		posDifference = position - previousPos
		previousPos = posDifference
	
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
		if (motion.x > -SOFT_MAX_SPEED):
			motion.x -= ACCELERATION * deltaOne
	elif Input.is_action_pressed("ctrl_right"):
		if (motion.x < SOFT_MAX_SPEED):
			motion.x += ACCELERATION * deltaOne
	else:
		motion.x = motion.x * (FRICTION * deltaOne)

func makeSlamParticle():
	var rrrect = player_collisions.shape.get_rect()
	var randPos = Vector2(randf_range(-rrrect.size.x, rrrect.size.x), randf_range(-rrrect.size.x, rrrect.size.x))
	
	var thingie = GameUtils.get_char_asset("GTeto", "Misc/SlamParticle.tscn").instantiate()
	get_parent().add_child(thingie)
	thingie.position = position + (randPos/3)
	thingie.rotation = atan2(velocity.y, velocity.x)
	thingie.z_index = z_index
