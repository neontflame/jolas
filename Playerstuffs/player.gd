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

@export var ATTACK_DMG:Dictionary = {
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
#endregion

#region Variables That Could Be of Assistance
var motion := Vector2(0.0, 0.0)
var jumping:bool = false
var holding_jump:bool = false

var attack:bool = false
var attackStrength:float = 2

var up_override:bool = false

var isSonicPhys:bool = false
var practicalAngle := 0.0

var movementEnabled:bool = true

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

func _enter_tree() -> void:
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
		visible = (curMap == GPStats.curMap)
	
	handleSonicPhys() #Everyone gets a Sonic Physics now.

func handleSonicPhys() -> void:
	isSonicPhys = true
	player_collisions.rotation = practicalAngle
	plySprite.rotation = lerp_angle(plySprite.rotation, practicalAngle, 0.2)
		
	# Sonic Physix
	if is_on_floor():
		if (up_direction.y > 0.3) && (abs(motion.x) < SOFT_MAX_SPEED * 0.3):
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
			
		
func handleMovement() -> void:
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
		
	# jumpfuck
	if PlayerUtils.is_jump_just_pressed() and (is_on_floor() or jumpsDone < JUMP_COUNT):
		jumpsDone += 1
		if isSonicPhys:
			motion.y = JUMP_VELOCITY * deltaOne
		else:
			motion.y = JUMP_VELOCITY * deltaOne * -floorSinCos.y
			motion.x += JUMP_VELOCITY * deltaOne * -floorSinCos.x
		
		motion.y -= abs(motion.x/2) * deltaOne * sin(get_floor_angle())
		jumping = true
		holding_jump = true
	
	if holding_jump:
		if motion.y >= 0 || !PlayerUtils.is_jump_pressed():
			holding_jump = false
	
	# Floor Physicque
	var slopeMult := (2 if (!Input.is_action_pressed("ctrl_left") && !Input.is_action_pressed("ctrl_right")) else 1)
	var slopeAdd = 0
	if is_on_floor():
		practicalAngle = get_floor_normal().angle() + PI/2
		floorSinCos = get_floor_normal()
		
		if (rad_to_deg(get_floor_angle()) > 5):
			# sei la angulos sao estranhos
			slopeAdd = (SLOPE_VEL_ADD * deltaOne) * floorSinCos.x * slopeMult
	else:
		slopeAdd = 0
	
	# walkfucks
	motion.x += slopeAdd
	if Input.is_action_pressed("ctrl_left"):
		if (motion.x > -SOFT_MAX_SPEED * deltaOne):
			motion.x -= ACCELERATION * deltaOne
	elif Input.is_action_pressed("ctrl_right"):
		if (motion.x < SOFT_MAX_SPEED * deltaOne):
			motion.x += ACCELERATION * deltaOne
	else:
		motion.x = motion.x * (FRICTION * deltaOne) + slopeAdd
	
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
		
	# Not Physix but we ball
	plySprite.position.x = randf_range(-shakeForce, shakeForce)
	plySprite.position.y = randf_range(-shakeForce, shakeForce)

func handleCamera() -> void:
	$Camera2D.position.x = lerp($Camera2D.position.x, (velocity.x / 10) + camOffset.x, 0.2) + randf_range(-camShakeForce, camShakeForce)
	$Camera2D.position.y = lerp($Camera2D.position.y, ((velocity.y if is_on_floor else -velocity.y) / 10) + camOffset.y, 0.2) + randf_range(-camShakeForce, camShakeForce)
	
	if abs(motion.x) > SOFT_MAX_SPEED * 1.25:
		idealZoom = 0.825
	else:
		idealZoom = 1
	$Camera2D.zoom = Vector2(	lerp($Camera2D.zoom.x, idealZoom, 0.05), 
								lerp($Camera2D.zoom.y, idealZoom, 0.05))

# roubei do breno creditos pra ele
func change_state(new_state):
	if new_state != null:
		# muda os estados
		previous_state = current_state
		current_state = new_state
		# ativa as funcoes dos estados
		previous_state.exit_state()
		current_state.enter_state()

func connectAttack(_stunFrames:float, fromBehind:bool = false, vel:Vector2 = Vector2(0, 0)):
	# increaseCombo()
	stunFrames = _stunFrames
	if vel != Vector2(0, 0):
		motion.y = vel.y
		motion.x = (vel.x if fromBehind else -vel.x)

func increaseCombo():
	comboFrames = 180.0
	combo += 1

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

func get_multi_status():
	return (GPStats.is_multiplayer && is_multiplayer_authority()) || (!GPStats.is_multiplayer)

func get_invuln():
	return (invulnFrames > 0) || fullInvuln

func level_up():
	# isso aqui ja depende mais do personagem
	# mas por enquanto sure
	for key in ATTACK_DMG.keys():
		ATTACK_DMG_LVL[key] = ATTACK_DMG[key] * GPStats.level
	print('seus ataques agora sao:')
	print(ATTACK_DMG_LVL)

func add_xp(xp:float):
	if GPStats.charObject == self:
		GPStats.xp += xp

## TODOs:
# implementar hitboxes tipo as de jogo de luta 
# pq eu sei que vao ter personagens que jogam tal como estes
# ah eu ja fiz isso lmfao
## faz uma hitbox! knockAngle e em degraus btw
func make_hitbox(offset:Vector2, scale:Vector2, _damage:float, _knockback:float, _knockAngle:float):
	var m_api = Engine.get_main_loop().root.get_multiplayer()
	
	if m_api.multiplayer_peer is ENetMultiplayerPeer:
		MultiplayerMayhem._player_make_hitbox.rpc(get_multiplayer_authority(), offset, scale, _damage, _knockback, _knockAngle)
	
	make_hitbox_actual(offset, scale, _damage, _knockback, _knockAngle)

func make_hitbox_actual(offset:Vector2, scale:Vector2, _damage:float, _knockback:float, _knockAngle:float):
	var hitbox = load("res://Gamestuffs/UsefulShits/Hitbox.tscn").instantiate()
	hitbox.position = offset
	hitbox.setUp(self, scale, _damage, _knockback, _knockAngle)
	hitboxCoisos.add_child(hitbox)
	hitbox.fixAngles()

## e tipo o [method make_hitbox] so que com segundos antes
func make_hitbox_timed(seconds:float, offset:Vector2, scale:Vector2, _damage:float, _knockback:float, _knockAngle:float):
	await make_hitbox(offset, scale, _damage, _knockback, _knockAngle)
	await get_tree().create_timer(seconds).timeout
	delete_hitboxes()

func delete_hitboxes():
	var m_api = Engine.get_main_loop().root.get_multiplayer()
	
	if m_api.multiplayer_peer is ENetMultiplayerPeer:
		MultiplayerMayhem._player_delete_hitboxes.rpc(get_multiplayer_authority())
	
	delete_hitboxes_actual()

func delete_hitboxes_actual():
	for hit in hitboxCoisos.get_children():
		hitboxes.erase(hit)
		hit.queue_free()

func hitbox_connect(hit:OffensiveHitbox):
	pass
