extends CharacterBody2D
class_name PlayerObject

#region State Machine
@onready var state_machine: Node = $StateMachine
var current_state = null
var previous_state = null
#endregion

#region Params
@export_category('Gameplay')
@export_group('Parameters')
@export var FLOOR_ACCELERATION = 62.5
@export var AIR_ACCELERATION = 30
@export var SOFT_MAX_SPEED = 600
@export var GRAVITY = 25.0
@export var JUMP_VELOCITY = -625
@export var SLOPE_VEL_ADD = 30
@export var FLOOR_FRICTION = 0.9125
@export var AIR_FRICTION = 0.9995
@export var JUMP_COUNT = 1

@export var ATTACK_DMG:Dictionary[String, float] = {
	'default': 1
}

@export_group('Technical shit')
@export var player_collisions:CollisionShape2D
@export var sfx_player:AudioStreamPlayer2D
@export var multiplayerName:RichTextLabel
@export var coolCamera:Camera2D
@export var hitboxCoisos:Node2D

@export_category('Animations')
@export var plySprite:AnimatedSprite2D

@export var MULTI_SENDOVER:Array[String] = []
#endregion 

#region Interesitng Variables
# Weeeeeeeeeeeird stuff goin on here. Tread Lightlyyyuhh
const WeirdMultiplier = 100
signal updateShit(velocity:Vector2)
var deltaOne:float = 1.0
var floorSinCos := Vector2(0.0, 0.0)
var idealZoom := 1.0

var shakeForce := 0.0
var camShakeForce := 0.0

var hp := 0.0
var invulnFrames := 30.0
var fullInvuln := false

var combo := 0
var comboFrames := 0.0

var stunFrames := 0.0
var jumpsDone:int = 1

var hitboxes:Array = []

@onready var ATTACK_DMG_LVL:Dictionary = ATTACK_DMG.duplicate(true)

@onready var canSpeedZoomCam:bool = (OptionsUtils.get_prefs_info()['speedZoom'] == 1)
#endregion

#region Variables That Could Be of Assistance
## isso e o que voce vai estar usando ao inves do velocity
var motion := Vector2(0.0, 0.0)
var jumping:bool = false
var holding_jump:bool = false

# porque eu ia ter usado isso ia ser tao mais impratico
# var attack:bool = false
# var attackStrength:float = 2

var up_override:bool = false

var isSonicPhys:bool = false
var practicalAngle := 0.0

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
	current_state = state_machine.st_floor
	previous_state = state_machine.st_floor
	PlayerUtils.set_default_zoom()

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
	while stunFrames > 0:
		stunFrames -= 1 * deltaOne
		return
	if current_state.has_method("update"): current_state.update()
	
	updateShit.emit(motion)
	var coolFlip = (-1 if plySprite.flip_h else 1)
	if hitboxCoisos.scale.x != coolFlip:
		hitboxCoisos.scale.x = coolFlip
		for hit in hitboxCoisos.get_children():
			hit.fixAngles()
	
	velocity = motion.rotated(up_direction.angle() + PI/2)
	move_and_slide()
	
	if comboFrames > 0:
		comboFrames -= 1 * deltaOne
	else:
		combo = 0
	
	if current_state != state_machine.st_hurt:
		if invulnFrames > 0:
			invulnFrames -= 1 * deltaOne
			plySprite.self_modulate.a = 0.5
		else:
			plySprite.self_modulate.a = 1
	
	if GPStats.is_multiplayer:
		if is_multiplayer_authority():
			curMap = GPStats.curMap
			send_params()
		visible = (curMap == GPStats.curMap)
	
	handleSonicPhys() #Everyone gets a Sonic Physics now.

func handleSonicPhys() -> void:
	isSonicPhys = true
	player_collisions.rotation = practicalAngle
	plySprite.rotation = lerp_angle(plySprite.rotation, practicalAngle, 0.2)
		
	# Sonic Physix
	if is_on_floor():
		if (up_direction.y > -0.001) && (abs(motion.x) < SOFT_MAX_SPEED * 0.75):
			# print('Get Outta Here')
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

var slopeMult := 1
var slopeAdd = 0
var slopeFactor = 0.0
var ACCELERATION := 0.0
var FRICTION := 0.0

func handleMovement() -> void:
	if not get_multi_status(): return
	# Go my acceleratione.
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
		
	# jumpfuck
	if PlayerUtils.is_jump_just_pressed() and (is_on_floor() or jumpsDone <= JUMP_COUNT):
		jumpsDone += 1
		if isSonicPhys:
			motion.y = JUMP_VELOCITY * deltaOne
		else:
			motion.y = JUMP_VELOCITY * deltaOne * -floorSinCos.y
			motion.x += JUMP_VELOCITY * deltaOne * -floorSinCos.x
		
		motion.y -= abs(motion.x/2) * deltaOne * sin(get_floor_angle())
		jumping = true
		holding_jump = true
		on_jump(jumpsDone)
	
	if holding_jump:
		if motion.y >= 0 || !PlayerUtils.is_jump_pressed():
			holding_jump = false
	
	# walkfucks
	motion.x += slopeAdd
	if walkingEnabled:
		if Input.is_action_pressed("ctrl_left"):
			if (motion.x > -SOFT_MAX_SPEED * slopeFactor * deltaOne):
				motion.x -= ACCELERATION * deltaOne
		elif Input.is_action_pressed("ctrl_right"):
			if (motion.x < SOFT_MAX_SPEED * slopeFactor * deltaOne):
				motion.x += ACCELERATION * deltaOne
		else:
			motion.x = motion.x * (FRICTION * deltaOne)

func handlePhys() -> void:
	# Air Physicque
	if not is_on_floor():
		practicalAngle = 0.0
		if (holding_jump): 
			motion.y += (GRAVITY / 1.5) * deltaOne
		else: 
			motion.y += GRAVITY * deltaOne
		
	if is_on_ceiling():
		motion.y = 10
	if is_on_wall():
		motion.x = 0
	
	# Floor Physicque
	slopeMult = (2 if (!Input.is_action_pressed("ctrl_left") && !Input.is_action_pressed("ctrl_right")) else 1)
	if is_on_floor():
		practicalAngle = get_floor_normal().angle() + PI/2
		floorSinCos = get_floor_normal()
		
		if (rad_to_deg(get_floor_angle()) > 5):
			# sei la angulos sao estranhos
			slopeAdd = (SLOPE_VEL_ADD * deltaOne) * floorSinCos.x * slopeMult
		else:
			slopeAdd = 0
		slopeFactor = 1.0 - (abs(floorSinCos.x) / 2.5)
		# print(slopeFactor)
	else:
		slopeAdd = 0
		slopeFactor = 1.0
	
	# Not Physix but we ball
	plySprite.position.x = randf_range(-shakeForce, shakeForce)
	plySprite.position.y = randf_range(-shakeForce, shakeForce)

var idealerZoom = 1.0

func handleCamera() -> void:
	$Camera2D.position.x = lerp($Camera2D.position.x, (velocity.x / 10) + camOffset.x, 0.2) + randf_range(-camShakeForce, camShakeForce)
	$Camera2D.position.y = lerp($Camera2D.position.y, ((velocity.y if is_on_floor else -velocity.y) / 10) + camOffset.y, 0.2) + randf_range(-camShakeForce, camShakeForce)
	
	if (abs(motion.x) > SOFT_MAX_SPEED * 1.25) && canSpeedZoomCam:
		idealerZoom = PlayerUtils.get_camera_zoom(idealZoom - 0.15)
	else:
		idealerZoom = PlayerUtils.get_camera_zoom(idealZoom)
	$Camera2D.zoom = Vector2(	lerp($Camera2D.zoom.x, idealerZoom, 0.05), 
								lerp($Camera2D.zoom.y, idealerZoom, 0.05))

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

func yeowch(hpLost:float, fromBehind:bool = false, vel:Vector2 = Vector2(250, -250)):
	if get_multi_status():
		if !get_invuln():
			if current_state.name == 'Death':
				return false
			play_sfx('Hit1')
			stunFrames = 2
			hp -= hpLost
			motion.y = vel.y
			motion.x = (abs(vel.x) if fromBehind else -abs(vel.x))
			invulnFrames = 120.0
			if (hp <= 0):
				change_state(state_machine.st_death)
			else:
				change_state(state_machine.st_hurt)
			return true
	
func play_sfx(name:String, volumeDB:float = 0.0):
	if sfx_player.playing: sfx_player.stop()
	sfx_player.stream = load("res://Gamestuffs/Sounds/Ingame/" + name + ".ogg")
	sfx_player.volume_db = GeneralUtils.get_volume_db('sfx', volumeDB)
	sfx_player.play()

func play_char_sfx(name:String, char:String, volumeDB:float = 0.0):
	if sfx_player.playing: sfx_player.stop()
	sfx_player.stream = load("res://Playerstuffs/Characters/" + char + "/Sounds/" + name + ".ogg")
	sfx_player.volume_db = GeneralUtils.get_volume_db('sfx', volumeDB)
	sfx_player.play()

func get_invuln():
	return (invulnFrames > 0) || fullInvuln

#region Ataques e Hitboxes
func connectAttack(_stunFrames:float, fromBehind:bool = false, vel:Vector2 = Vector2(0, 0)):
	# increaseCombo()
	# print(_stunFrames)
	stunFrames = _stunFrames
	if vel != Vector2(0, 0):
		motion.y = vel.y
		motion.x = (vel.x if fromBehind else -vel.x)

func increaseCombo():
	comboFrames = 180.0
	combo += 1

## faz uma hitbox! knockAngle e em degraus e o angulo 0 aponta pra Direita btw
## direçao do knockAngle e horaria
func make_hitbox(offset:Vector2, scale:Vector2, _damage:float, _knockback:float, _knockAngle:float, hitboxId:String = ''):
	var m_api = Engine.get_main_loop().root.get_multiplayer()
	
	if m_api.multiplayer_peer is ENetMultiplayerPeer:
		MultiplayerMayhem._player_make_hitbox.rpc(get_multiplayer_authority(), offset, scale, _damage, _knockback, _knockAngle, hitboxId)
	
	make_hitbox_actual(offset, scale, _damage, _knockback, _knockAngle, hitboxId)

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

func hitbox_connect(hit:OffensiveHitbox):
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
#endregion

#region Utilidades (Multiplayer)
# coisos que existem Explicitamente pra serem usados no multiplayer
func get_multi_status():
	return (GPStats.is_multiplayer && is_multiplayer_authority()) || (!GPStats.is_multiplayer)

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
#endregion
