extends PlayerObject

# o NEON usando um ENUM?????
# could such a thing EXIST??????????
enum HookStatus {
	UNHOOKED,
	TAIL_THROWN,
	GOING
}

@export var caudaVision:Node2D

@export var caudaRaycast:ShapeCast2D
@export var caudaLine:Line2D
@export var caudaEnd:Sprite2D
@export var targetSpr:AnimatedSprite2D

@export var hookableNonFloors:Array = []

var tweenEngracinho:Tween
var tweenEngracinhoDois:Tween
var tweenProprio:Tween #tweena o breno
var tweenTime:float = 0.25

var hookedOntoPos:Vector2 = Vector2.ZERO

var hooking:int = false
var isGonnaHook:bool = false
var spinny:bool = false

@export var hookChances:int = 2
var hooksTried:int = 0

var pastMotion:Vector2
var coolMotion:Vector2

var canSpinny:bool = true

func hookOnto(aim:Vector2):
	isGonnaHook = false
	if hooksTried >= hookChances: return
	hooksTried += 1
	plySprite.play("caudaThrow")
	
	hooking = HookStatus.TAIL_THROWN
	
	if caudaRaycast.is_colliding():
		if caudaRaycast.get_collider(0) is Area2D:
			hookedOntoPos = caudaRaycast.get_collider(0).global_position
		else:
			hookedOntoPos = caudaRaycast.get_collision_point(0)
	else:
		hookedOntoPos = global_position + (aim * 256)
	
	caudaRaycast.collision_mask = collision_mask || collision_layer
	caudaRaycast.rotation = get_angle_to(hookedOntoPos)
	
	plySprite.flip_h = (hookedOntoPos.x < global_position.x)
	motion = Vector2.from_angle(caudaRaycast.rotation)
	
	tweenEngracinho = create_tween()
	# indentaçao meio estranha mas a gente bola
	tweenEngracinho.tween_method(func(value):
		caudaLine.set_point_position(1, value),
	caudaLine.get_point_position(0),
	hookedOntoPos - global_position, 
	tweenTime)
	
	if caudaRaycast.is_colliding():
		tweenEngracinho.finished.connect(hookOntoPt2)
	else:
		tweenEngracinho.finished.connect(hookOntoPtFail)

func hookOntoPtFail():
	plySprite.play("caudaPullback")
	tweenEngracinhoDois = create_tween()
	# indentaçao meio estranha mas a gente bola
	tweenEngracinhoDois.tween_method(func(value):
		caudaLine.set_point_position(1, value)
		,
	caudaLine.get_point_position(1),
	caudaLine.get_point_position(0), 
	tweenTime)
	
	tweenEngracinhoDois.finished.connect(func():
		hooking = HookStatus.UNHOOKED
		plySprite.play("jump")
		motion = pastMotion
	)

func hookOntoPt2():
	plySprite.play("caudaPullback")
	hooking = HookStatus.GOING
	var storedMotion = max(abs(pastMotion.x), abs(pastMotion.y))
	var theAngle = caudaRaycast.rotation
	
	var uhhhhhhPos:float = global_position.distance_to(hookedOntoPos)
	
	var leTime:float = ((uhhhhhhPos / 300) * tweenTime)
	
	coolMotion = Vector2.from_angle(theAngle).round() * storedMotion * 2
	
	var hookiehit = make_hitbox(Vector2.ZERO,
		Vector2(3.78, 6.25),
		ATTACK_DMG_LVL['default'],
		30,
		-45,
		"hookie"
	)
	
	tweenProprio = create_tween()
	# indentaçao meio estranha mas a gente bola
	tweenProprio.tween_method(func(value):
		var diff:Vector2 = value - global_position
		
		hookiehit.knockAngle = deg_to_rad(diff.angle())
		
		global_position = value
		if test_move(global_transform, diff):
			cancelHookOnto()
			delete_hitboxes("hookie")
			await get_tree().process_frame
			motion = Vector2.from_angle(theAngle).round() * storedMotion * 2
			if is_on_wall_side('left', true):
				motion.x = (storedMotion / 2)
			if is_on_wall_side('right', true):
				motion.x = -(storedMotion / 2)
			# print(motion)
		,
	global_position,
	hookedOntoPos, 
	leTime)
	
	tweenEngracinhoDois = create_tween()
	# indentaçao meio estranha mas a gente bola
	tweenEngracinhoDois.tween_method(func(value):
		caudaLine.set_point_position(1, value)
		,
	caudaLine.get_point_position(1),
	caudaLine.get_point_position(0), 
	leTime)
	
	tweenProprio.finished.connect(func():
		hooking = HookStatus.UNHOOKED
	)

func cancelHookOnto():
	if tweenEngracinho:
		if tweenEngracinho.is_valid(): tweenEngracinho.kill()
	if tweenEngracinhoDois:
		if tweenEngracinhoDois.is_valid(): tweenEngracinhoDois.kill()
	if tweenProprio:
		if tweenProprio.is_valid(): tweenProprio.kill()
	hooking = HookStatus.UNHOOKED

func getSpinny():
	cancelHookOnto()
	if hooking == HookStatus.GOING:
		motion = coolMotion
	else:
		motion = pastMotion
	jumping = false
	jumpsDone = JUMP_COUNT # Isto arruma ok
	spinny = true
	plySprite.play("caudaSpin")
	var hits = make_hitbox(Vector2.ZERO,
		Vector2(7, 7),
		ATTACK_DMG_LVL['default'],
		50,
		-45,
		"speeeen"
	)
	hits.rotation_degrees = 45
	plySprite.rotation_degrees = 0

func noSpinny():
	delete_hitboxes("speeeen")
	spinny = false

var spinnyOftened:bool = false
func spinny_everySoOften():
	if spinnyOftened: return
	spinnyOftened = true
	delete_hitboxes("speeeen")
	var hits = make_hitbox(Vector2.ZERO,
		Vector2(7, 7),
		ATTACK_DMG_LVL['default'],
		50,
		-45,
		"speeeen"
	)
	hits.rotation_degrees = 45
	play_sfx("Whoosh", -5.0)

func _process(_delta: float) -> void:
	caudaEnd.position = caudaLine.get_point_position(1)

func hitbox_connect(hit:OffensiveHitbox, type:String):
	# print('connec')
	motion.y = abs(motion.y) * -1.095
	connectAttack(4)

func _physics_process(delta: float) -> void:
	if hooking == HookStatus.UNHOOKED:
		pastMotion = motion
		
	super._physics_process(delta)
	caudaVision.visible = hooking
	caudaEnd.rotation = caudaRaycast.rotation
	if caudaRaycast.is_colliding():
		targetSpr.global_position = caudaRaycast.get_collision_point(0)
	else:
		targetSpr.position = Vector2.from_angle(caudaRaycast.rotation) * 256
	targetSpr.visible = isGonnaHook
	
	if spinny:
		spriteRotatesByItself = true
		plySprite.rotation_degrees += (-45 if plySprite.flip_h else 45)
		if fmod(plySprite.rotation_degrees, 360) == 0:
			spinny_everySoOften()
		else:
			spinnyOftened = false
	else:
		spriteRotatesByItself = false
	
	if is_on_floor():
		isGonnaHook = false
		hooksTried = 0

func on_respawn(maxOutHp:bool):
	isGonnaHook = false
	cancelHookOnto()
	for i in range(2):
		await get_tree().process_frame
	registerHookables()

func on_land():
	super.on_land()
	noSpinny()
	canSpinny = true

func on_jump(jumpCount:int):
	super.on_jump(jumpCount)
	noSpinny()

func yeowch(hpLost:float, vel:Vector2 = Vector2(250, -250)):
	cancelHookOnto()
	noSpinny()
	super.yeowch(hpLost, vel)

func registerHookables():
	print("[breno] Ok registrando !")
	caudaRaycast.clear_exceptions()
	for child in MapUtils.map.find_children("*", "Area2D", true, false):
		var script = child.get_script()
		var leClass = child.get_script().get_global_name() if script else ""
		if not hookableNonFloors.has(leClass):
			caudaRaycast.add_exception(child)
