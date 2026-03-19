extends PlayerObject

@export_category('Sketcher params')
@export var SLIDE_FRICTION := 1.0
@export var ELEC_GAUGE_MAX := 10.0
@export var REBOUND_LIMIT := 2

@export var rightSweep:RayCast2D
@export var leftSweep:RayCast2D

var ELECTRICITY := 5.0

var isParkouring := false
var reboundsDone := 0

var isSliding := false
signal slideTriggered

func _process(_delta: float) -> void:
	if ELECTRICITY > ELEC_GAUGE_MAX:
		ELECTRICITY = ELEC_GAUGE_MAX

func handlePhys():
	super.handlePhys()
	plySprite.material.set_shader_parameter("line_thickness", ELECTRICITY/5.0)

func handleParkour():
	if sweeping_mob('right')[0] && Input.is_action_pressed("ctrl_right"):
		jumping = true
		invulnFrames = 10.0
		motion.x = 900
		motion.y = -400
		sweeping_mob('right')[1].yeowch(ATTACK_DMG_LVL['vault'], true, Vector2(50.0, 200.0))
	if sweeping_mob('left')[0] && Input.is_action_pressed("ctrl_left"):
		jumping = true
		invulnFrames = 10.0
		motion.x = -900
		motion.y = -400
		sweeping_mob('left')[1].yeowch(ATTACK_DMG_LVL['vault'], true, Vector2(-50.0, 200.0))

func sweeping_mob(dir:StringName) -> Array:
	var isTrued := false
	var mob:MobObject = null
	match dir:
		'right':
			isTrued = rightSweep.is_colliding() && rightSweep.get_collider() is MobObject
			if isTrued:
				mob = rightSweep.get_collider()
		'left':
			isTrued = leftSweep.is_colliding() && leftSweep.get_collider() is MobObject
			if isTrued:
				mob = leftSweep.get_collider()
	return [isTrued, mob]

func handleMovement() -> void:
	super.handleMovement()
	handleSlide()
	if Input.is_action_pressed('ctrl_2'):
		handleParkour()
	if Input.is_action_just_pressed("ctrl_down") and is_on_floor():
		isSliding = true
		slideTriggered.emit()
	
	if isSliding and is_on_floor():
		FRICTION = SLIDE_FRICTION

func hasElec(limit:float = 0.0):
	return (ELECTRICITY > limit)

func handleSlide():
	if abs(motion.x) < 10 \
	or is_on_wall() \
	or not is_on_floor():
		isSliding = false
		if is_on_floor():
			FRICTION = FLOOR_FRICTION
	
	# Shimmy
	if is_on_floor() and is_on_ceiling():
		# print('MOVE motherfucker MOOOVEEEEE')
		isSliding = true
		slideTriggered.emit()
		motion.x += sign(motion.x) * 200.0
			
	walkingEnabled = not isSliding
	player_collisions.disabled = isSliding
	$CollisionShape2D2.disabled = not isSliding

func hitbox_connect(hit:OffensiveHitbox):
	print('connec')
	connectAttack(5.0, (hitboxCoisos.scale.x == -1))
	
	match hit.coolId:
		'slide':
			ELECTRICITY += 1
			invulnFrames = 10.0
		_:
			ELECTRICITY += 2
