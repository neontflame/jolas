@icon("uid://bnwgwk0kxuq4y")
extends CharacterBody2D
class_name PlayerObject

#region State Machine
@onready var state_machine: Node = $StateMachine
var current_state = null
var previous_state = null
#endregion

#region Params
@export_category('Character Specific Interactions')
@export var can_jump_mid_air: bool = true
@export_category('Gameplay')
@export_group('Parameters')
@export var FLOOR_ACCELERATION: float = 62.5
@export var AIR_ACCELERATION: float = 30.0
@export var FLOOR_BRAKE: float = 0.0
@export var SOFT_MAX_SPEED: float = 600.0
@export var GRAVITY: float = 25.0
@export var JUMP_VELOCITY: float = -750
@export var SLOPE_VEL_ADD: float = 30.0
@export var FLOOR_FRICTION: float = 0.9125
@export var AIR_FRICTION: float = 0.9995
@export var JUMP_COUNT: int = 1

var acceleration_modifiers: Dictionary = {}

@export var ATTACK_DMG:Dictionary[String, float] = {
	'default': 1
}

@export_group('Technical shit')
@export var player_collisions:CollisionShape2D
@export var sfx_player:AudioStreamPlayer2D
@export var multiplayerName:RichTextLabel
@export var coolCamera: Camera2D
var base_camera_offset: Vector2
@export var hitboxCoisos:Node2D

@export var leftWallness:ShapeCast2D
@export var rightWallness:ShapeCast2D

@export_category('Animations')
@export var plySprite:AnimatedSprite2D

@export var MULTI_SENDOVER:Array[String] = []
#endregion 

#region Interesitng Variables
# Weeeeeeeeeeeird stuff goin on here. Tread Lightlyyyuhh
var isPlayerGrounded: bool

const WeirdMultiplier = 100
# signal updateShit(velocity:Vector2)
var deltaOne:float = 1.0
var floorSinCos := Vector2(0.0, 0.0)
var idealZoom := 1.0

var shakeForce:float = 0.0
var camShakeForce:float = 0.0
var revertShake:bool = false

var hp:float = 0.0
var invulnFrames:int = 30
var fullInvuln:bool = false

var combo:int = 0
var comboFrames:int = 0
signal comboIncrease
signal comboReset

var stunFrames:int = 0
var jumpsDone:int = 1

var hitboxes:Array = []

@onready var ATTACK_DMG_LVL:Dictionary = ATTACK_DMG.duplicate(true)
@onready var canSpeedZoomCam:bool = (OptionsUtils.get_prefs_info()['speedZoom'] == 1)

var flooredFrames:int = 0
#endregion

#region Variables That Could Be of Assistance
## isso e o que voce vai estar usando ao inves do velocity
var motion := Vector2.ZERO
var prevAirMotion := Vector2.ZERO

var jumping:bool = false
var holding_jump:bool = false

# porque eu ia ter usado isso ia ser tao mais impratico
# var attack:bool = false
# var attackStrength:float = 2

var up_override:bool = false

var isSonicPhys: bool = true
var practicalAngle := 0.0

var spriteRotatesByItself: bool = false

var movementEnabled:bool = true
var walkingEnabled:bool = true #mostly for abilities to use

var camOffset := Vector2(0.0, 0.0)
#endregion

#region Multiplayer Bull Shit
var playerID:Variant = -1
var curMap:String = ''
#endregion

func _ready() -> void:
	hp = GPStats.maxHP
	# comece a state machine
	for state in state_machine.get_children():
		state.States = state_machine
		state.Player = self
		state.StateName = state.name
		state.setup()
	current_state = state_machine.st_floor
	previous_state = state_machine.st_floor
	
	if FLOOR_BRAKE == 0:
		FLOOR_BRAKE = FLOOR_ACCELERATION
	PlayerUtils.set_default_zoom()
	
	setup_camera()

func _enter_tree() -> void:
	# CODIGO DE QUANDO ENTRA NO MULTIPLAYER FAVOR NAO MEXER !!!
	if GPStats.is_multiplayer:
		playerID = name.to_int()
		set_multiplayer_authority(playerID)
		movementEnabled = get_multi_status()
		
		if is_multiplayer_authority():
			GPStats.charObject = self
			multiplayerName.text = GameUtils.username
			multiplayerName.visible = true
			multiplayerName.position.y = player_collisions.position.y - (player_collisions.shape.get_rect().size.y / 2) - 24
	
func _physics_process(delta: float) -> void:
	deltaOne = delta * 60
	regenWallCollmasks()
	while stunFrames > 0:
		stunFrames -= 1
		return
	if current_state.has_method("update"): current_state.update()
	
	# updateShit.emit(motion)
	var coolFlip = (-1 if plySprite.flip_h else 1)
	if hitboxCoisos.scale.x != coolFlip:
		hitboxCoisos.scale.x = coolFlip
		for hit in hitboxCoisos.get_children():
			hit.fixAngles()
	
	# print(velocity, motion)
	velocity = motion.rotated(up_direction.angle() + PI/2)
	move_and_slide()
	
	if comboFrames > 0:
		comboFrames -= 1
	else:
		if combo != 0: resetCombo()
	

	
	if GPStats.is_multiplayer:
		if is_multiplayer_authority():
			curMap = GPStats.curMap
			send_params()
		visible = (curMap == GPStats.curMap)
	
	handleSpriteShenanigans()
	handleSonicPhys() #Everyone gets a Sonic Physics now.

func handleSpriteShenanigans():
	if current_state != state_machine.st_hurt:
		if invulnFrames > 0:
			invulnFrames -= 1
			plySprite.self_modulate.a = 0.5
		else:
			plySprite.self_modulate.a = 1
	
	if not spriteRotatesByItself:
		if is_on_floor(): plySprite.rotation = practicalAngle
		else: plySprite.rotation = lerp_angle(plySprite.rotation, practicalAngle, 0.1)
	
	plySprite.position.x = randf_range(-shakeForce, shakeForce)
	plySprite.position.y = randf_range(-shakeForce, shakeForce)

var cameFromAir:bool = false

func handleSonicPhys() -> void:
	player_collisions.rotation = practicalAngle

	# Sonic Physix
	if is_on_floor():
		if cameFromAir:
			motion = prevAirMotion.rotated(-(get_floor_normal().angle() + PI/2))
			cameFromAir = false
			on_land() 	# Ok eu acho q isso e prova o suficiente de q o 
						# codigo de fisica do jogador e meio bagunçado pra crl
						# mas a gente bola
		if (up_direction.y > -0.001) && (abs(motion.x) < SOFT_MAX_SPEED * 0.75):
			# print('Get Outta Here')
			on_fall_from_slope()
		up_direction = get_floor_normal()
	else:
		cameFromAir = true
		flooredFrames = 0
		if up_direction != Vector2(0.0, -1.0):
			var prevmotion := Vector2(
				motion.x * -up_direction.y - motion.y * up_direction.x,
				motion.y * -up_direction.y + motion.x * up_direction.x,
				)
			up_direction = Vector2(0.0, -1.0)
			motion = prevmotion


var slopeMult := 1
var slopeAdd = 0
var slopeFactor = 0.0
var ACCELERATION := 0.0
var FRICTION := 0.0

func handleMovement(new_floor_acceleration: float = FLOOR_ACCELERATION, new_air_acceleration: float = AIR_ACCELERATION, new_soft_max_speed: float = SOFT_MAX_SPEED) -> void:
	if not get_multi_status(): return
	# Go my acceleratione.
	if is_on_floor():
		ACCELERATION = new_floor_acceleration
		FRICTION = FLOOR_FRICTION
	else:
		ACCELERATION = new_air_acceleration
		FRICTION = AIR_FRICTION
		
	if (!movementEnabled):
		motion.x = motion.x * (FRICTION)
		return
		
	# jumpfuck
	if can_player_jump():
		jumpsDone += 1
		if isSonicPhys:
			# print("pode pular")
			motion.y = JUMP_VELOCITY
		else:
			motion.y = JUMP_VELOCITY * -floorSinCos.y
			motion.x += JUMP_VELOCITY * -floorSinCos.x
		motion.y -= abs(motion.x/2) * sin(get_floor_angle())
		jumping = true
		holding_jump = true
		on_jump(jumpsDone)
	
	#if holding_jump:
		#if motion.y >= 0 || !PlayerUtils.is_jump_pressed():
			#holding_jump = false
	
	if jumping and holding_jump:
		if PlayerUtils.is_jump_released() and motion.y < 0.0:
			# print("eugh")
			motion.y = motion.y / 1.5
			holding_jump = false
	
	# walkfucks
	motion.x += slopeAdd
	if walkingEnabled:
		if Input.is_action_pressed("ctrl_left"):
			if (motion.x > -new_soft_max_speed * slopeFactor):
				if (motion.x > 0 and is_on_floor()):
					motion.x -= FLOOR_BRAKE
				else:
					motion.x -= ACCELERATION
		elif Input.is_action_pressed("ctrl_right"):
			if (motion.x < new_soft_max_speed * slopeFactor):
				if (motion.x < 0 and is_on_floor()):
					motion.x += FLOOR_BRAKE
				else:
					motion.x += ACCELERATION
		else:
			motion.x = motion.x * (FRICTION)

func handlePhys() -> void:
	# Floor Physicque
	slopeMult = (2 if (!Input.is_action_pressed("ctrl_left") && !Input.is_action_pressed("ctrl_right")) else 1)
	if is_on_floor():
		flooredFrames += 1
		practicalAngle = get_floor_normal().angle() + PI/2
		floorSinCos = get_floor_normal()
		
		if (rad_to_deg(get_floor_angle()) > 5):
			# sei la angulos sao estranhos
			slopeAdd = (SLOPE_VEL_ADD) * floorSinCos.x * slopeMult
		else:
			slopeAdd = 0
		slopeFactor = 1.0 - (abs(floorSinCos.x) / 2.5)
		# print(slopeFactor)
	else:
		slopeAdd = 0
		slopeFactor = 1.0
		prevAirMotion = motion

var idealerZoom = 1.0

func apply_player_gravity(custom_gravity: float = GRAVITY):
	var delta = get_physics_process_delta_time()
	var gravity_value = (custom_gravity * 60.0) * delta
	if not is_on_floor():
		if is_on_ceiling():
			motion.y = 10
		practicalAngle = 0.0
		motion.y += gravity_value
	if is_on_ceiling():
		motion.y = abs(motion.y) * 0.5
	if (is_on_wall() and flooredFrames >= 3) or is_on_wall_only():
		motion.x = 0

#region Camera
func setup_camera():
	coolCamera.position_smoothing_enabled = false
	await get_tree().process_frame
	await get_tree().process_frame
	coolCamera.reset_smoothing()
	coolCamera.position_smoothing_enabled = true

func handleCamera() -> void:
	#neon_cam()
	neon_zoom()
	breno_cam()

func neon_cam():
	coolCamera.position.x = lerp(coolCamera.position.x, (velocity.x / 10) + camOffset.x, 0.2) + randf_range(-camShakeForce, camShakeForce)
	coolCamera.position.y = lerp(coolCamera.position.y, ((velocity.y if is_on_floor else -velocity.y) / 10) + camOffset.y, 0.2) + randf_range(-camShakeForce, camShakeForce)

func neon_zoom():
	if (abs(motion.x) > SOFT_MAX_SPEED * 1.25) && canSpeedZoomCam:
		idealerZoom = PlayerUtils.get_camera_zoom(idealZoom - 0.15)
	else:
		idealerZoom = PlayerUtils.get_camera_zoom(idealZoom)
	coolCamera.zoom = Vector2(	lerp(coolCamera.zoom.x, idealerZoom, 0.05), 
								lerp(coolCamera.zoom.y, idealerZoom, 0.05))

func breno_cam():
	var delta = get_physics_process_delta_time()
	var screen_half_x = get_viewport_rect().size.x * 0.8 / coolCamera.zoom.x
	var screen_half_y = get_viewport_rect().size.y * 1.2 / coolCamera.zoom.y
	var forward_offset_x = camOffset.x
	if abs(get_real_velocity().x) > 100.0:
		forward_offset_x += 200.0 * sign(get_real_velocity().x)

	var predicted_x = global_position.x + forward_offset_x

	var margin_left  = coolCamera.limit_left + screen_half_x + 5
	var margin_right = coolCamera.limit_right - screen_half_x - 5

	var can_move_forward = predicted_x > margin_left and predicted_x < margin_right
	
	if coolCamera.position.y != 0.0:
		coolCamera.position.y = lerp(coolCamera.position.y, 0.0, 0.1)
	
	if can_move_forward:
		# pode avançar pra frente
		coolCamera.position.x = lerp(coolCamera.position.x, forward_offset_x, delta)
	else:
		# não pode... volta
		coolCamera.position.x = lerp(coolCamera.position.x, base_camera_offset.x, delta * 2) # 2 pra voltar mais rápido
	coolCamera.position += Vector2(1, 1) * randf_range(-camShakeForce, camShakeForce)

func clamp_camera_offset(desired_offset: Vector2) -> Vector2:
	var screen_half_x = get_viewport_rect().size.x / coolCamera.zoom.x
	var screen_half_y = get_viewport_rect().size.y / coolCamera.zoom.y

	var predicted = global_position + desired_offset

	var min_x = coolCamera.limit_left + screen_half_x
	var max_x = coolCamera.limit_right - screen_half_x

	var min_y = coolCamera.limit_top + screen_half_y
	var max_y = coolCamera.limit_bottom - screen_half_y

	predicted.x = clamp(predicted.x, min_x, max_x)
	predicted.y = clamp(predicted.y, min_y, max_y)
	
	print(predicted)
	return predicted - global_position
#endregion 

# roubei do breno creditos pra ele
func change_state(new_state):
	if new_state != null:
		# muda os estados
		previous_state = current_state
		current_state = new_state
		# ativa as funcoes dos estados
		previous_state.exit_state()
		current_state.enter_state()

func add_xp(xp:float):
	if GPStats.charObject == self:
		GPStats.xp += xp

func level_up():
	# isso aqui ja depende mais do personagem
	# mas por enquanto sure
	for key in ATTACK_DMG.keys():
		ATTACK_DMG_LVL[key] = ATTACK_DMG[key] * GPStats.level
	# print('seus ataques agora sao:')
	# print(ATTACK_DMG_LVL)

func yeowch(hpLost:float, vel:Vector2 = Vector2(250, -250)):
	if get_multi_status():
		if !get_invuln():
			# stop_sfx()
			# await get_tree().create_timer(0.01).timeout
			spawnNumber(hpLost)
			if current_state.name == 'Death':
				return false
			
			var medianVel = (vel.x + vel.y)/2
			if medianVel < 400:
				play_sfx('Hit1')
			if medianVel >= 400 and medianVel < 800:
				play_sfx('Hit2')
			if medianVel >= 800:
				play_sfx('Hit3')
			
			stunFrames = 2
			hp -= hpLost
			motion.y = vel.y
			motion.x = vel.x
			invulnFrames = 120.0
			if (hp <= 0):
				change_state(state_machine.st_death)
			else:
				change_state(state_machine.st_hurt)
			return true
	
func play_sfx(soundName:String, volumeDB:float = 0.0):
	if sfx_player.playing: sfx_player.stop()
	sfx_player.stream = load("res://Gamestuffs/Sounds/Ingame/" + soundName + ".wav")
	sfx_player.volume_db = volumeDB
	sfx_player.play()

func play_char_sfx(soundName:String, char:String, volumeDB:float = 0.0):
	if sfx_player.playing: sfx_player.stop()
	sfx_player.stream = load("res://Playerstuffs/Characters/" + char + "/Sounds/" + soundName + ".wav")
	sfx_player.volume_db = volumeDB
	sfx_player.play()

func stop_sfx():
	sfx_player.stop()

func get_invuln():
	return (invulnFrames > 0) || fullInvuln

#region Ataques e Hitboxes
func connectAttack(_stunFrames:float, vel:Vector2 = Vector2.ZERO):
	# increaseCombo()
	# print(_stunFrames)
	stunFrames = _stunFrames
	if vel != Vector2.ZERO:
		motion.y = vel.y
		motion.x = vel.x

func increaseCombo():
	comboFrames = 180.0
	combo += 1
	comboIncrease.emit()

func resetCombo():
	combo = 0
	comboReset.emit()

## faz uma hitbox! knockAngle e em degraus e o angulo 0 aponta pra Direita btw
## direçao do knockAngle e horaria

func make_hitbox(offset:Vector2, scale:Vector2, _damage:float, _knockback:float, _knockAngle:float, hitboxId:String = ''):
	var m_api = Engine.get_main_loop().root.get_multiplayer()
	
	if m_api.multiplayer_peer is ENetMultiplayerPeer:
		MultiplayerMayhem._player_make_hitbox.rpc(get_multiplayer_authority(), offset, scale, _damage, _knockback, _knockAngle, hitboxId)
	
	return make_hitbox_actual(offset, scale, _damage, _knockback, _knockAngle, hitboxId)

func make_hitbox_actual(offset:Vector2, scale:Vector2, _damage:float, _knockback:float, _knockAngle:float, hitboxId:String = ''):
	if GPStats.is_multiplayer && curMap != GPStats.curMap: return
	var hitbox = load("res://Gamestuffs/UsefulShits/Hitbox.tscn").instantiate()
	var theRotation = 0.0
	if plySprite.flip_h:
		theRotation = Vector2.from_angle(player_collisions.rotation)
		theRotation.y = theRotation.y * -1
		theRotation = theRotation.angle()
	else:
		theRotation = player_collisions.rotation
		
	hitbox.position = offset.rotated(theRotation)
	hitbox.rotation = theRotation
	hitbox.setUp(self, scale, _damage, _knockback, _knockAngle)
	hitboxCoisos.add_child(hitbox)
	hitbox.coolId = hitboxId
	hitbox.fixAngles()
	return hitbox

## e tipo o [method make_hitbox] so que com segundos antes
func make_hitbox_timed(seconds:float, offset:Vector2, scale:Vector2, _damage:float, _knockback:float, _knockAngle:float, hitboxId:String = ''):
	await make_hitbox(offset, scale, _damage, _knockback, _knockAngle, hitboxId)
	await get_tree().create_timer(seconds).timeout
	delete_hitboxes()

func delete_hitboxes(hitboxId:String = ''):
	var m_api = Engine.get_main_loop().root.get_multiplayer()
	
	if m_api.multiplayer_peer is ENetMultiplayerPeer:
		MultiplayerMayhem._player_delete_hitboxes.rpc(get_multiplayer_authority(), hitboxId)
	
	delete_hitboxes_actual(hitboxId)

func delete_hitboxes_actual(hitboxId:String = ''):
	for hit in hitboxCoisos.get_children():
		if hitboxId == '':
			hitboxes.erase(hit)
			hit.queue_free()
		else:
			if hit.coolId == hitboxId:
				hitboxes.erase(hit)
				hit.queue_free()

func hitbox_connect(hit:OffensiveHitbox, type:String):
	pass

func hitbox_exists(hitboxId:String = ''):
	for hit in hitboxCoisos.get_children():
		if hit.coolId == hitboxId:
			return true
	return false
#endregion

#region Utilidades (Scripting)
func on_jump(jumpNum:int):
	pass

func on_land():
	jumpsDone = 1
	jumping = false

func on_pre_spring():
	pass

func on_spring(vel:Vector2):
	pass

func on_fall_from_slope():
	motion.y = -50
	print(motion)
	up_direction = Vector2(0.0, -1.0)

func on_respawn(maxOutHp:bool):
	pass
#endregion

#region Utilidades (Multiplayer)
# coisos que existem Explicitamente pra serem usados no multiplayer
func get_multi_status():
	if GPStats.is_multiplayer:
		if JolasGame.instance:
			return is_multiplayer_authority() and (not JolasGame.instance.hud.isWriting)
	return true

func send_params():
	if len(MULTI_SENDOVER) <= 0: return
	var properties:Dictionary[String, Variant] = {}
	
	for prop in MULTI_SENDOVER:
		properties[prop] = get(prop)
	
	var m_api = Engine.get_main_loop().root.get_multiplayer()
	
	if m_api.multiplayer_peer is ENetMultiplayerPeer:
		MultiplayerMayhem._player_send_params.rpc(get_multiplayer_authority(), properties)

func get_params(properties:Dictionary[String, Variant]):
	if GPStats.charObject == self: return
	for prop in properties.keys():
		# print(name, ' ', prop, ': ', get(StringName(prop)))
		set(StringName(prop), properties[prop])
#endregion

#region Utilidades (Misc)
func onUnpause():
	canSpeedZoomCam = (OptionsUtils.get_prefs_info()['speedZoom'] == 1)
	PlayerUtils.set_default_zoom()

func setMotion(x:float, y:float, addX:bool = false, addY:bool = false):
	if addX:
		if (x < motion.x and sign(x) == -1)\
		or (x > motion.x and sign(x) == 1):
			motion.x += x * 2
		else:
			motion.x += x
	else:
		motion.x = x
	
	if addY:
		if (y < motion.y and sign(y) == -1)\
		or (y > motion.y and sign(y) == 1):
			motion.y += y * 2
		else:
			motion.y += y
	else:
		motion.y = y

func spawnNumber(quant):
	var numble = load("res://Gamestuffs/UsefulShits/Numbs.tscn").instantiate()
	get_parent().add_child(numble)
	numble.global_position = global_position - Vector2(0, 32)
	numble.set_text(quant)

func regenWallCollmasks():
	if leftWallness.collision_mask != collision_mask:
		leftWallness.collision_mask = collision_mask
	if rightWallness.collision_mask != collision_mask:
		rightWallness.collision_mask = collision_mask
func is_on_wall_side(side:StringName, sensitive:bool = false):
	match side:
		'left':
			if sensitive:
				return leftWallness.is_colliding()
			return is_on_wall() && leftWallness.is_colliding()
		'right':
			if sensitive:
				return rightWallness.is_colliding()
			return is_on_wall() && rightWallness.is_colliding()
		_:
			return is_on_wall()

func can_player_jump() -> bool:
	return PlayerUtils.is_jump_just_pressed() and (is_on_floor() or (jumpsDone <= JUMP_COUNT and can_jump_mid_air))

func get_floor_acceleration(accel_modifier: float = FLOOR_ACCELERATION) -> float:
	return accel_modifier

func get_air_acceleration(air_accel_modifier: float = AIR_ACCELERATION) -> float:
	return air_accel_modifier
#endregion
