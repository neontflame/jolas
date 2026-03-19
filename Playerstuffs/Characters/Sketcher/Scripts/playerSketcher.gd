extends PlayerObject

@export_category('Sketcher params')
@export var SLIDE_FRICTION := 1.0
@export var ELEC_GAUGE_MAX := 10.0

var ELECTRICITY := 10.0

var isSliding := false

func _process(delta: float) -> void:
	if ELECTRICITY > ELEC_GAUGE_MAX:
		ELECTRICITY = ELEC_GAUGE_MAX
	if abs(motion.x) < 10 \
	or is_on_wall() \
	or not is_on_floor():
		isSliding = false
		if is_on_floor():
			FRICTION = FLOOR_FRICTION
	
	if isSliding:
		if is_on_floor() and is_on_ceiling():
			isSliding = true
			motion.x *= 10
			
	walkingEnabled = not isSliding
	player_collisions.disabled = isSliding
	$CollisionShape2D2.disabled = not isSliding

func handleMovement() -> void:
	super.handleMovement()
	if Input.is_action_just_pressed("ctrl_down"):
		isSliding = true
	
	if isSliding and is_on_floor():
		FRICTION = SLIDE_FRICTION

func hasElec(limit:float = 0.0):
	return (ELECTRICITY > limit)

func hitbox_connect(hit:OffensiveHitbox):
	print('connec')
	connectAttack(5.0, (hitboxCoisos.scale.x == -1))
