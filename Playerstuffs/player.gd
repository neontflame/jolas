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

@export_group('Technical shit')
@export var player_collisions:CollisionShape2D
@export var sfx_player:AudioStreamPlayer2D

@export_category('Animations')
@export var plySprite:AnimatedSprite2D
#endregion 

#region Interesitng Variables
# Weeeeeeeeeeeird stuff goin on here. Tread Lightlyyyuhh
const WeirdMultiplier = 100
signal updateShit(velocity:Vector2)
var deltaOne := 0.0
var floorSinCos := Vector2(0.0, 0.0)
var idealZoom := 1.0

var shakeForce := 0.0
var camShakeForce := 0.0

var hp := 0.0
#endregion

#region Variables That Could Be of Assistance
var motion := Vector2(0.0, 0.0)
var jumping:bool = false
var holding_jump:bool = false
var isSonicPhys:bool = false
var practicalAngle := 0.0

var movementEnabled:bool = true

var camOffset := Vector2(0.0, 0.0)

var playerID:Variant = -1
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
	
func _physics_process(delta: float) -> void:
	deltaOne = delta * 60
	if current_state.has_method("update"): current_state.update()
	
	updateShit.emit(motion)
	
	velocity = motion.rotated(up_direction.angle() + PI/2)
	move_and_slide()
	
	handleSonicPhys() #Everyone gets a Sonic Physics now.

func handleSonicPhys() -> void:
	isSonicPhys = true
	player_collisions.rotation = practicalAngle
	plySprite.rotation = lerp_angle(plySprite.rotation, practicalAngle, 0.2)
		
	# Sonic Physix
	if is_on_floor():
		if (up_direction.y > 0.8) && (abs(motion.x) < SOFT_MAX_SPEED * 0.3):
			print('Get Outta Here')
			motion.y = -50
			print(motion)
			up_direction = Vector2(0.0, -1.0)
		up_direction = get_floor_normal()
	else:
		if up_direction != Vector2(0.0, -1.0):
			print('AIR TIME')
			var prevmotion := Vector2(
				motion.x * -up_direction.y - motion.y * up_direction.x,
				motion.y * -up_direction.y + motion.x * up_direction.x,
				)
			print(floorSinCos)
			print(prevmotion)
			up_direction = Vector2(0.0, -1.0)
			motion = prevmotion
			
		
func handleMovement() -> void:
	# Go my acceleratione.
	var ACCELERATION := 0.0
	var FRICTION := 0.0
	if is_on_floor():
		ACCELERATION = FLOOR_ACCELERATION
		FRICTION = FLOOR_FRICTION
		jumping = false
	else:
		ACCELERATION = AIR_ACCELERATION
		FRICTION = AIR_FRICTION
		
	if (!movementEnabled):
		motion.x = motion.x * (FRICTION * deltaOne)
		return
		
	# jumpfuck
	if Input.is_action_pressed("ctrl_up") and is_on_floor():
		if isSonicPhys:
			motion.y = JUMP_VELOCITY * deltaOne
		else:
			motion.y = JUMP_VELOCITY * deltaOne * -floorSinCos.y
			motion.x += JUMP_VELOCITY * deltaOne * -floorSinCos.x
		
		motion.y -= abs(motion.x/2) * deltaOne * sin(get_floor_angle())
		jumping = true
		holding_jump = true
	
	if holding_jump:
		if motion.y >= 0 || !Input.is_action_pressed("ctrl_up"):
			holding_jump = false
			
	# walkfucks
	if Input.is_action_pressed("ctrl_left"):
		if (motion.x > -SOFT_MAX_SPEED * deltaOne):
			motion.x -= ACCELERATION * deltaOne
	elif Input.is_action_pressed("ctrl_right"):
		if (motion.x < SOFT_MAX_SPEED * deltaOne):
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
	if is_on_floor():
		practicalAngle = get_floor_normal().angle() + PI/2
		floorSinCos = get_floor_normal()
		
		var slopeMult := (2 if (!Input.is_action_pressed("ctrl_left") && !Input.is_action_pressed("ctrl_right")) else 1)
		if (rad_to_deg(get_floor_angle()) > 1):
			# sei la angulos sao estranhos
			motion.x += (SLOPE_VEL_ADD * deltaOne) * floorSinCos.x * slopeMult
	
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

func play_sfx(name:String, volumeDB:float = 0.0):
	if sfx_player.playing: sfx_player.stop()
	sfx_player.stream = load("res://Playerstuffs/Sounds/" + name + ".ogg")
	sfx_player.volume_db = volumeDB
	sfx_player.play()

func play_char_sfx(name:String, char:String, volumeDB:float = 0.0):
	if sfx_player.playing: sfx_player.stop()
	sfx_player.stream = load("res://Playerstuffs/Characters/" + char + "/Sounds/" + name + ".ogg")
	sfx_player.volume_db = volumeDB
	sfx_player.play()

func get_multi_status():
	return (GPStats.is_multiplayer && is_multiplayer_authority()) || (!GPStats.is_multiplayer)
