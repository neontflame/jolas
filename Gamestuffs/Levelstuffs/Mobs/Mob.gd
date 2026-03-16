extends CharacterBody2D
class_name MobObject

# ok uhhhhhhhhhh O mob e basicamente um player so que mais cutdown
# iuhul
var deltaOne := 0.0

#region State Machine
@onready var state_machine: Node = $StateMachine
var current_state = null
var previous_state = null
#endregion

#region Params
@export_group('Parameters')
@export var ACCELERATION = 62.5
@export var MAX_SPEED = 600
@export var GRAVITY = 25.0
@export var JUMP_VELOCITY = -625
@export var FRICTION = 0.9125

@export var maxHP:float = 10
@onready var hp:float = maxHP
@export var level:float = 1.0
@export var strength:float = 1.0
@export var xpGrant:float = 10.0

@export_group('Technical shit')
@export var collisions:CollisionShape2D

@export var collArea:Area2D
@export var collAreaCollision:CollisionShape2D

@export var playerDetector:Area2D

@export var sfx_player:AudioStreamPlayer2D

@export_category('Animations')
@export var leSprite:AnimatedSprite2D
#endregion 

#region Othershits
var detectingPlayer:bool = false

var touchingPlayer:bool = false
var touchedPlayer:PlayerObject
var touchedBody

var theHarmer:PlayerObject

var isHurting := false
var isDead := false
var stunFrames := 0.0
#endregion

func _ready() -> void:
	collAreaCollision.shape = collisions.shape
	collAreaCollision.scale = collisions.scale
	
	# comece a state machine
	for state in state_machine.get_children():
		state.States = state_machine
		state.Mob = self
		state.StateName = state.name
	current_state = state_machine.st_default
	previous_state = state_machine.st_default
	
	collArea.connect("body_entered", onTouched)
	collArea.connect("body_exited", onUntouched)

func _physics_process(delta: float) -> void:
	deltaOne = delta * 60
	if stunFrames > 0:
		stunFrames -= 1 * deltaOne
		return
	if current_state.has_method('update'): current_state.update()
	$Label.text = GeneralUtils.display_number(hp) + '/' + GeneralUtils.display_number(maxHP)
	move_and_slide()

func handlePhys():
	if !is_on_floor():
		velocity.y += GRAVITY * deltaOne
		
	if is_on_wall():
		velocity.x = 0

func change_state(new_state):
	if new_state != null:
		# muda os estados
		previous_state = current_state
		current_state = new_state
		# ativa as funcoes dos estados
		previous_state.exit_state()
		current_state.enter_state()

# touchy
func onTouched(body):
	touchedBody = body
	if body is PlayerObject:
		touchedPlayer = body
		touchingPlayer = true

func onUntouched(body):
	if body == touchedBody:
		touchedBody = null
	if body is PlayerObject:
		if body == touchedPlayer:
			touchedPlayer = null
		touchingPlayer = false

# woah mais coisas copiadas do player
func yeowch(hpLost:float, fromBehind:bool = false, vel:Vector2 = Vector2(250, -250)):
	print(vel)
	if isDead:
		return false
	if theHarmer:
		theHarmer.increaseCombo()
	stunFrames = 2.0
	play_sfx('Hit2')
	hp -= hpLost
	velocity.y = vel.y
	velocity.x = (vel.x if fromBehind else -vel.x)
	if (hp <= 0):
		if theHarmer: 
			theHarmer.add_xp(xpGrant)
		change_state(state_machine.st_death)
		isDead = true
	else:
		change_state(state_machine.st_hurt)
	return true

func play_sfx(name:String, volumeDB:float = 0.0):
	if sfx_player.playing: sfx_player.stop()
	sfx_player.stream = load("res://Gamestuffs/Sounds/Ingame/" + name + ".ogg")
	sfx_player.volume_db = GeneralUtils.get_volume_db('sfx', volumeDB)
	sfx_player.play()

func play_mob_sfx(name:String, mob:String, volumeDB:float = 0.0):
	if sfx_player.playing: sfx_player.stop()
	sfx_player.stream = load("res://Gamestuffs/Levelstuffs/Mobs/" + mob + "/Sounds/" + name + ".ogg")
	sfx_player.volume_db = GeneralUtils.get_volume_db('sfx', volumeDB)
	sfx_player.play()

#woah uma coisa Simulando o player ?
func inputSimulation(xInput:int, yInput:int):
	if xInput != 0:
		if abs(velocity.x) < MAX_SPEED:
			velocity.x += ACCELERATION * xInput
	elif is_on_floor():
		velocity.x = velocity.x * FRICTION
	
	if yInput == -1:
		if is_on_floor():
			velocity.y -= JUMP_VELOCITY

# detector de player
func pd_body_entered(body: Node2D) -> void:
	if body is PlayerObject:
		detectingPlayer = true

func pd_body_exited(body: Node2D) -> void:
	if body is PlayerObject:
		detectingPlayer = false

# voce pode tentar combar eles agora
func handlePlyHits(harmPlayer:bool = true):
	if touchingPlayer:
		if touchedPlayer.attack:
			theHarmer = touchedPlayer
			touchedPlayer.connectAttack(2, 
			(position.x > touchedPlayer.position.x), 
			Vector2(-touchedPlayer.motion.x, -abs(touchedPlayer.motion.y))
			)
			yeowch(touchedPlayer.attackStrength, 
			(position.x > touchedPlayer.position.x)
			)
		elif harmPlayer:
			theHarmer = null
			touchedPlayer.yeowch(strength, 
			(position.x < touchedPlayer.position.x)
			)
