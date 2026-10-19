@icon("uid://xnav228uyus6")
extends CharacterBody2D
class_name MobObject

# ok uhhhhhhhhhh O mob e basicamente um player so que mais cutdown
# iuhul
#region State Machine
@onready var state_machine: Node = $StateMachine
var current_state = null
var previous_state = null
#endregion

#region Params
@export_group('Parameters')
@export var ACCELERATION = 62.5
@export var MAX_SPEED = 600.0
@export var GRAVITY = 25.0
@export var JUMP_VELOCITY = -625.0
@export var FRICTION = 0.9125

@export var maxHP:float = 10
@onready var hp:float = maxHP
@export var level:float = 1.0
@export var strength:float = 1.0
@export var xpGrant:float = 10.0

@export var USES_BODY_AS_HITBOX:bool = true

@export var KNOCKBACK_ON_PLY_BODY_HIT:Vector2 = Vector2(250, -250)

## uma chance de 1 em quantos pra dropar esse item ?
@export var possibleDrops:Dictionary[String, int] = {}

@export_group('Technical shit')
@export var collisions:CollisionShape2D

@export var collArea:Area2D
@export var collAreaCollision:CollisionShape2D

@export var playerDetector:Area2D

@export var sfx_player:AudioStreamPlayer2D

@export var healthBar:Bar

@export var screen_notifier: VisibleOnScreenNotifier2D

@export_group("Character Specific Interactions")
@export_subgroup("Can Get Hooked?")
## se o objeto pode ser ganchado pelo onerb.
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var USES_BODY_AS_HOOKABLE: bool = true
## deixe isso em 0.0 para não ter timer de stun nenhum. isso desativa momentaneamente a colisao de dano.
@export var onerb_hook_stun_timer: float = 3.0
@export_group("")

@export_category('Animations')
@export var leSprite:AnimatedSprite2D
#endregion 

#region Othershits
var detectingPlayer:bool = false

var touchingPlayer:bool = false
var touchedPlayer:PlayerObject
var touchedBody

var theHarmer:PlayerObject

var isHurting:bool = false
var isDead:bool = false
var stunFrames:float = 0.0 # char nao se mexe mas o estado dele ainda da update
var freezeFrames:float = 0.0 # o char e fisicamente incapaz de fazer qualquer coisa

var isEnabled:bool = false
#endregion

func _ready() -> void:
	collAreaCollision.shape = collisions.shape
	collAreaCollision.scale = collisions.scale
	
	screen_notifier.screen_entered.connect(on_screen_entered)
	
	# comece a state machine
	for state in state_machine.get_children():
		state.States = state_machine
		state.Mob = self
		state.StateName = state.name
	current_state = state_machine.st_default
	previous_state = state_machine.st_default
	
	collArea.connect("body_entered", onTouched)
	collArea.connect("body_exited", onUntouched)
	
	if USES_BODY_AS_HOOKABLE:
		set_collision_layer_value(16, true)

func _physics_process(delta: float) -> void:
	healthBar.progress = hp / maxHP
	healthBar.visible = not (isDead or not detectingPlayer)
	
	if freezeFrames > 0:
		freezeFrames -= 1 * delta * 60
		return
	
	if stunFrames > 0:
		stunFrames -= 1 * delta
	else:
		if collAreaCollision.disabled:
			collAreaCollision.set_deferred("disabled", false)
	if current_state.has_method('update'): current_state.update()
	# $Label.text = GeneralUtils.display_number(hp) + '/' + GeneralUtils.display_number(maxHP)
	move_and_slide()

func handlePhys():
	if !is_on_floor():
		# null check pq testando uma vez descobrimos que 
		# o henry so fucking matou o jogo ao inves do mob
		# boa """"""""henry""""""""
		# -neon
		if GRAVITY != null: velocity.y += GRAVITY
		
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
func yeowch(hpLost:float, vel:Vector2 = Vector2(250, -250)):
	if isDead:
		return false
	spawnNumber(hpLost)
	if theHarmer:
		theHarmer.increaseCombo()
	
	if freezeFrames <= 0.0:
		freezeFrames = (hpLost / 5) / 60
	
	var medianVel = (vel.x + vel.y)/2
	if medianVel < 400:
		play_sfx('Hit1', 5)
	if medianVel >= 400 and medianVel < 800:
		play_sfx('Hit2', 5)
	if medianVel >= 800:
		play_sfx('Hit3', 5)
	hp -= hpLost
	
	# var harmer_pos: Vector2 = theHarmer.global_position - global_position
	
	velocity.y = vel.y
	# velocity.x = (vel.x if harmer_pos.x > 0 else -vel.x)
	velocity.x = vel.x
	if (hp <= 0):
		hp = 0
		if theHarmer: 
			theHarmer.add_xp(xpGrant)
		change_state(state_machine.st_death)
		dropItems()
		isDead = true
	else:
		change_state(state_machine.st_hurt)
	return true

func stun_mob() -> void:
	if onerb_hook_stun_timer <= 0.0:
		return
	stunFrames = onerb_hook_stun_timer
	collAreaCollision.set_deferred("disabled", true)
	velocity = Vector2.ZERO

func play_sfx(soundName:String, volumeDB:float = 0.0, pitch_scale: float = 1.0, file_type: String = ".wav"):
	if sfx_player.playing: sfx_player.stop()
	sfx_player.stream = load("res://Soundstuffs/SFX/Ingame/" + soundName + file_type)
	sfx_player.volume_db = volumeDB
	sfx_player.pitch_scale = pitch_scale
	sfx_player.play()

func play_mob_sfx(name:String, mob:String, volumeDB:float = 0.0, pitch_scale: float = 1.0, file_type: String = ".wav"):
	if sfx_player.playing: sfx_player.stop()
	sfx_player.stream = load("res://Gameplaystuffs/Mobs/" + mob + "/Sounds/" + name + file_type)
	sfx_player.volume_db = volumeDB
	sfx_player.pitch_scale = pitch_scale
	sfx_player.play()

#woah uma coisa Simulando o player ?
func inputSimulation(xInput:int, yInput:int):
	if xInput != 0:
		if abs(velocity.x) < MAX_SPEED:
			velocity.x += ACCELERATION * xInput
	elif is_on_floor():
		if FRICTION:
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
	if touchingPlayer && USES_BODY_AS_HITBOX:
		if harmPlayer and stunFrames <= 0.0:
			theHarmer = null
			touchedPlayer.yeowch(strength, KNOCKBACK_ON_PLY_BODY_HIT)

func spawnNumber(quant):
	var numble = load("res://Gameplaystuffs/UsefulShits/Numbs.tscn").instantiate()
	get_parent().add_child(numble)
	numble.global_position = global_position - Vector2(0, 32)
	numble.set_text(quant)

func dropItems():
	if len(possibleDrops) > 0:
		for itemcool in possibleDrops:
			if randi_range(1, possibleDrops[itemcool]) == 1:
				MapUtils.spawn_item(itemcool, global_position)

#region Scripting
func on_screen_entered() -> void:
	isEnabled = true
#endregion
