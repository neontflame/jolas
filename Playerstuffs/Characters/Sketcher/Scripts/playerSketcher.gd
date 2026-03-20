extends PlayerObject

@export_category('Sketcher params')
@export var SLIDE_FRICTION := 1.0
@export var ELEC_GAUGE_MAX := 10.0
@export var REBOUND_LIMIT := 2
@export var ELEC_USAGE:Dictionary[String, float] = {}

@export var rightSweep:RayCast2D
@export var leftSweep:RayCast2D
@export var homingArea:Area2D

@export var dashLine:Line2D
@export var boostLine:Line2D

var ELECTRICITY := 5.0

var ctrl1held := 0.0

var isParkouring := false
var vaultCooldown := 0.0
var reboundsDone := 0

var isSliding := false
signal slideTriggered

var isBoosting := false

var ctrl1diff = 12 # 5 frames
var canDash := true

func _process(_delta: float) -> void:
	if ELECTRICITY < 0.0:
		ELECTRICITY = 0.0
	if ELECTRICITY > ELEC_GAUGE_MAX:
		ELECTRICITY = ELEC_GAUGE_MAX
	
	if vaultCooldown > 0.0:
		vaultCooldown -= deltaOne
	
	handleLine(dashLine)
	handleLine(boostLine)
	
	if movementEnabled:
		handleCtrlOne()

func handleLine(line:Line2D):
	line.global_position = Vector2(0, 0)
	if line.get_point_count() > 12:
		line.remove_point(0)
	line.add_point(global_position + Vector2(0, -7 + randi_range(-2, 2)))

func handleCtrlOne():
	if is_on_floor():
		canDash = true
	
	if current_state.name != 'Hurt'		\
	and current_state.name != 'Death'	\
	and current_state.name != 'Dash':
		if Input.is_action_just_pressed("ctrl_1"):
			ctrl1held = 0.0
		if Input.is_action_pressed("ctrl_1"):
			ctrl1held += 1.0
			if ctrl1held > ctrl1diff:
				isBoosting = true
		if Input.is_action_just_released("ctrl_1"):
			isBoosting = false
			print(ctrl1held)
			if ctrl1held <= ctrl1diff and canDash:
				change_state(state_machine.st_dash)
				canDash = false

func handlePhys():
	super.handlePhys()
	plySprite.material.set_shader_parameter("line_thickness", 
	(ELECTRICITY/5.0 if isParkouring else 0.0))

func handleParkour():
	if hasElec() and vaultCooldown <= 0.0:
		if sweeping_mob('right')[0] && Input.is_action_pressed("ctrl_right"):
			vaultCooldown = 15.0
			print('vaulted')
			jumping = true
			ELECTRICITY -= ELEC_USAGE['vault']
			invulnFrames = 10.0
			motion.x = 900
			motion.y = -500
			sweeping_mob('right')[1].yeowch(ATTACK_DMG_LVL['vault'], true, Vector2(50.0, 200.0))
		if sweeping_mob('left')[0] && Input.is_action_pressed("ctrl_left"):
			vaultCooldown = 15.0
			print('vaulted')
			jumping = true
			ELECTRICITY -= ELEC_USAGE['vault']
			invulnFrames = 10.0
			motion.x = -900
			motion.y = -500
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
		isParkouring = true
	else:
		isParkouring = false
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
