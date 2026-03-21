extends PlayerObject

@export_category('Sketcher params')
@export var SLIDE_FRICTION := 1.0
@export var ELEC_GAUGE_MAX := 10.0
@export var REBOUND_LIMIT := 2
@export var ELEC_USAGE:Dictionary[String, float] = {}

@export var BOOST_MIN_SPEED := 1500.0

@export var rightSweep:RayCast2D
@export var leftSweep:RayCast2D
@export var downSweep:RayCast2D

@export var rightWallSweep:RayCast2D
@export var leftWallSweep:RayCast2D

@export var homingArea:Area2D

@export var dashLine:Line2D
@export var boostLine:Line2D

@export var boostSprite:AnimatedSprite2D

var ELECTRICITY:float = 5.0

var ctrl1held:float = 0.0

var isParkouring := false
var vaultCooldown := 0.0
var reboundsDone := 0
var reboundCountdown := 0.0

var isSliding:bool = false
signal slideTriggered

var isBoosting:bool = false

var ctrl1diff = 12 # 5 frames
var canDash:bool = true

func _process(_delta: float) -> void:
	if ELECTRICITY < 0.0:
		ELECTRICITY = 0.0
	if ELECTRICITY > ELEC_GAUGE_MAX:
		ELECTRICITY = ELEC_GAUGE_MAX
	
	if vaultCooldown > 0.0:
		vaultCooldown -= deltaOne
	
	if reboundCountdown > 0.0:
		reboundCountdown -= deltaOne
	
	handleLine(dashLine)
	handleLine(boostLine)
	
	handleBoost()
	if movementEnabled:
		handleCtrlOne()

func handleLine(line:Line2D):
	line.global_position = Vector2(0, 0)
	if line.get_point_count() > 12:
		line.remove_point(0)
	line.add_point(global_position + Vector2(0, -7 + randi_range(-2, 2)))

func makeAfterimage():
	var afterimg = GameUtils.get_char_asset("Sketcher", "Fx/Afterimage.tscn").instantiate()
	add_child(afterimg)
	afterimg.grabInfo(self)

func handleBoost():
	boostSprite.visible = isBoosting
	boostLine.visible = isBoosting
	boostSprite.rotation = plySprite.rotation
	boostSprite.flip_h = (motion.x < 0)
	boostSprite.offset.x = (30 if motion.x < 0 else -30)
	$Windstuff.volume_db = GeneralUtils.get_volume_db('sfx', 0)
	if not isBoosting:
		$Windstuff.stop()
		return
	
	if not hasElec():
		isBoosting = false
		return
	
	if not $Windstuff.playing:
		$Windstuff.play()
	
	if not hitbox_exists('boost'):
		make_hitbox(Vector2.ZERO,
		Vector2(8.105, 7.005),
		ATTACK_DMG_LVL['boost'],
		1300,
		315,
		'boost'
		)
		
	ELECTRICITY -= ELEC_USAGE['boost']
	if Input.is_action_pressed("ctrl_left") \
	or not Input.is_action_pressed("ctrl_right") and plySprite.flip_h:
		if (motion.x > -BOOST_MIN_SPEED):
			motion.x -= BOOST_MIN_SPEED
	else:
		if (motion.x < BOOST_MIN_SPEED):
			motion.x += BOOST_MIN_SPEED

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
				if not isBoosting and hasElec():
					isBoosting = true
					play_char_sfx('BoostBurst', 'Sketcher')
					boostLine.clear_points()
		if Input.is_action_just_released("ctrl_1"):
			delete_hitboxes('boost')
			isBoosting = false
			print(ctrl1held)
			if ctrl1held <= ctrl1diff and canDash and hasElec():
				change_state(state_machine.st_dash)
				canDash = false

var evryFrame := 0

func handlePhys():
	evryFrame += 1
	super.handlePhys()
	
	plySprite.material.set_shader_parameter("line_thickness", 
	(ELECTRICITY/5.0 if isParkouring else 0.0))
	if isParkouring:
		if evryFrame % 5 == 0:
			makeAfterimage()

func handleSonicPhys() -> void:
	isSonicPhys = true
	player_collisions.rotation = practicalAngle
	plySprite.rotation = lerp_angle(plySprite.rotation, practicalAngle, 0.2)
		
	# Sonic Physix
	if is_on_floor():
		# print(abs(motion.x), ' ', SOFT_MAX_SPEED, ' ')
		if (up_direction.y > -0.4) && (abs(motion.x) < SOFT_MAX_SPEED):
			if not isParkouring:
				print('Get Outta Here')
				motion.y = -50
				print(motion)
				up_direction = Vector2(0.0, -1.0)
		up_direction = get_floor_normal()
	else:
		if up_direction != Vector2(0.0, -1.0):
			# print('AIR TIME')
			var prevmotion := Vector2(
				motion.x * -up_direction.y - motion.y * up_direction.x,
				motion.y * -up_direction.y + motion.x * up_direction.x,
				)
			# print(floorSinCos)
			# print(prevmotion)
			up_direction = Vector2(0.0, -1.0)
			motion = prevmotion

var previousMotionY := 0.0
var isRebounding := false

func handleRebounds():
	if not is_on_floor():
		reboundCountdown = 30.0
		previousMotionY = motion.y
	if is_on_floor():
		if reboundCountdown > 0.0:
			if PlayerUtils.is_jump_pressed() && reboundsDone < REBOUND_LIMIT:
				if -abs(previousMotionY) < JUMP_VELOCITY:
					motion.y = -abs(previousMotionY) - 50
					reboundsDone += 1
					ELECTRICITY += ELEC_USAGE['rebound_reward']
		if reboundCountdown <= 0.0:
			reboundsDone = 0

func handleParkour():
	#if is_touching_elevation():
		#print('JUUUMPPP')
		#motion.y = -700
		#perdao skech mas nao tava funcionando certo :wilted_rose:
	ELECTRICITY -= ELEC_USAGE['parkour']
	if is_touching_wall('left'):
		up_direction = Vector2(1, 0)
	if is_touching_wall('right'):
		up_direction = Vector2(-1, 0)
	
	#if hasElec() and vaultCooldown <= 0.0:
		#if sweeping_mob('right')[0] && Input.is_action_pressed("ctrl_right"):
			#sweep_mob('right')
			#motion.x = 900
			#motion.y = -500
		#
		#if sweeping_mob('left')[0] && Input.is_action_pressed("ctrl_left"):
			#sweep_mob('left')
			#motion.x = -900
			#motion.y = -500

func sweep_mob(dir:StringName):
	vaultCooldown = 15.0
	print('vaulted')
	jumping = true
	invulnFrames = 30.0
	sweeping_mob(dir)[1].stunFrames = 15
	global_position.y = (sweeping_mob(dir)[1].global_position.y - 
						(sweeping_mob(dir)[1].collisions.shape.get_rect().size.y / 2))
	sweeping_mob(dir)[1].yeowch(ATTACK_DMG_LVL['vault'], true, Vector2(50.0, 200.0))

func sweeping_mob(dir:StringName) -> Array:
	var isTrued := false
	var mob:MobObject = null
	match dir:
		'right':
			isTrued = rightSweep.is_colliding() && rightSweep.get_collider() is MobObject \
			&& not rightSweep.get_collider().isDead
			if isTrued:
				mob = rightSweep.get_collider()
			else:
				return sweeping_mob('down')
		'left':
			isTrued = leftSweep.is_colliding() && leftSweep.get_collider() is MobObject \
			&& not leftSweep.get_collider().isDead
			if isTrued:
				mob = leftSweep.get_collider()
			else:
				return sweeping_mob('down')
		'down':
			isTrued = downSweep.is_colliding() && downSweep.get_collider() is MobObject \
			&& not downSweep.get_collider().isDead
			if isTrued:
				mob = downSweep.get_collider()
	return [isTrued, mob]

func handleMovement() -> void:
	super.handleMovement()
	handleSlide()
	handleRebounds()
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

func get_invuln():
	return (invulnFrames > 0) || fullInvuln || isBoosting || current_state.name == 'Dash'
	
func hitbox_connect(hit:OffensiveHitbox):
	print('connec')
	connectAttack(5.0, (hitboxCoisos.scale.x == -1))
	
	match hit.coolId:
		'slide':
			ELECTRICITY += 1
			invulnFrames = 10.0
		_:
			ELECTRICITY += 2

func is_touching_wall(which:String):
	match which:
		'left':
			return is_on_wall() \
			and leftWallSweep.is_colliding() \
			and leftWallSweep.get_collider() is StaticBody2D
		'right':
			return is_on_wall() \
			and rightWallSweep.is_colliding() \
			and rightWallSweep.get_collider() is StaticBody2D
		_:
			# Not a Real Direction dum-dum
			return false

func is_touching_elevation():
	for sweeper in [rightWallSweep, leftWallSweep]:
		return sweeper.is_colliding() \
		and sweeper.get_collider() is StaticBody2D
	return false
