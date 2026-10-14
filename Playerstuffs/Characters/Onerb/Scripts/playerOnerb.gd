extends PlayerObject

# o NEON usando um ENUM?????
# could such a thing EXIST??????????
enum HookStatus {
	UNHOOKED,
	TAIL_THROWN,
	GOING
}

@export_category("Onerb Components")
@export_group("Neon Shits")
@export var caudaVision:Node2D
@export var caudaRaycast:ShapeCast2D
@export var caudaLine:Line2D
@export var caudaEnd:Sprite2D
@export var targetSpr:AnimatedSprite2D
@export var hookableNonFloors:Array = []
@export_group("")
@export_group("Onerb Shits")
@export_subgroup("Gameplay Parameters")
@export var hook_distance_gap: float = 32.0
@export var max_hook_distance: float = 512.0
@export var hook_momentum_gap: float = 1200.0
@export_subgroup("")
@export var cauda_tip_area: Area2D
@export var cauda_tip_collision: CollisionShape2D
@export_group("")
@export_category("")

#region Onerb Shits
var last_motion: Vector2
var hook_momentum: float
var hook_aim_direction: Vector2
var preview_hook_position: Vector2
var next_hook_position: Vector2

signal hooked_at(hook_position: Vector2)
signal hook_failed
#endregion

var tweenEngracinho:Tween

@export var hookChances:int = 2
var hooksTried:int = 0

var canSpinny:bool = true

func _ready() -> void:
	super()
	caudaEnd.global_position = global_position
	
	# colisao da ponta da cauda
	cauda_tip_area.area_entered.connect(on_hooked_area)
	cauda_tip_area.body_entered.connect(on_hooked_body)
	
	# colisao para ativar o gancho em si
	hooked_at.connect(on_hooked_at)
	
	targetSpr.visible = false

#region Hook Mechanics
func can_hook() -> void:
	if Input.is_action_just_pressed("ctrl_2"):
		if hooksTried < hookChances:
			last_motion = motion
			hook_momentum = hook_momentum_gap if last_motion.length() <= hook_momentum_gap else last_motion.length()
			change_state(state_machine.hook_aim)
			motion = Vector2.ZERO

func release_hook() -> void:
	if not Input.is_action_pressed("ctrl_2"):
		hooksTried += 1
		preview_hook_position = global_position + (hook_aim_direction * max_hook_distance)
		play_char_sfx("ChickenSwing", "Onerb", 10.0, randf_range(0.8, 1.2), ".ogg")
		change_state(state_machine.hook_fire)

func on_hooked_area(area: Area2D) -> void:
	pass

func on_hooked_body(body: Node2D) -> void:
	if body is CurvedTerrainV2:
		hooked_at.emit(caudaEnd.global_position)
	elif body is MobObject:
		if body.USES_BODY_AS_HOOKABLE:
			hooked_at.emit(body.global_position)

func on_hooked_at(hook_position: Vector2) -> void:
	next_hook_position = hook_position
	change_state(state_machine.hook_move)

func move_hook_object() -> void:
	caudaEnd.global_position = caudaEnd.global_position.move_toward(preview_hook_position, hook_momentum * get_delta())
	caudaEnd.rotation = caudaRaycast.rotation
	caudaVision.visible = true

func return_hook_object() -> void:
	kill_tween_engracadinho()
	tweenEngracinho = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tweenEngracinho.tween_property(caudaEnd, "position", Vector2.ZERO, 0.25)
	await tweenEngracinho.finished
	caudaVision.visible = false

func force_hook_cancel() -> void:
	cauda_tip_collision.set_deferred("disabled", true)
	return_hook_object()

func handleCameraSpecial(camera_offset: Vector2) -> void:
	neon_zoom()
	var offset: Vector2 = 150.0 * camera_offset
	if camera_offset != Vector2.ZERO:
		coolCamera.position = offset
#endregion

#region Hook Aim
func handle_hook_aim() -> void:
	if caudaRaycast.is_colliding():
		targetSpr.global_position = caudaRaycast.get_collision_point(0)
	else:
		targetSpr.position = Vector2.from_angle(caudaRaycast.rotation) * caudaRaycast.target_position.x
#endregion

func getSpinny():
	force_hook_cancel()
	jumping = false
	jumpsDone = JUMP_COUNT # Isto arruma ok
	change_state(state_machine.spin_attack)
	if get_player_vector() == Vector2.ZERO:
		motion = last_motion
	else:
		motion = hook_momentum * get_player_vector()

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
	caudaLine.set_point_position(1, to_local(caudaEnd.global_position))

func hitbox_connect(hit:OffensiveHitbox, type:String):
	# print('connec')
	motion.y = abs(motion.y) * -1.095
	connectAttack(4)

#region Utilities
func on_respawn(maxOutHp:bool):
	super.on_respawn(maxOutHp)
	force_hook_cancel()
	for i in range(2):
		await get_tree().process_frame
	registerHookables()

func on_land():
	super()
	hooksTried = 0

func yeowch(hpLost:float, vel:Vector2 = Vector2(250, -250)):
	force_hook_cancel()
	super.yeowch(hpLost, vel)

func registerHookables():
	print("[breno] Ok registrando !")
	caudaRaycast.clear_exceptions()
	for child in MapUtils.map.find_children("*", "Area2D", true, false):
		var script = child.get_script()
		var leClass = child.get_script().get_global_name() if script else ""
		if not hookableNonFloors.has(leClass):
			caudaRaycast.add_exception(child)

func kill_tween_engracadinho() -> void:
	if tweenEngracinho and tweenEngracinho.is_valid():
		tweenEngracinho.kill()
#endregion
