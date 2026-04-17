extends "res://Playerstuffs/StateMachinery/airSt.gd"

var isDashing:bool = false
var hasDashed:bool = false
var theCooldown:SceneTreeTimer

func setup() -> void:
	theCooldown = get_tree().create_timer(0.01)

func enter_state():
	super.enter_state()
	hasDashed = false
	isDashing = false
	
	if Player.rebounding:
		Player.play_char_sfx('ReboundYI', 'Passo')
		Player.plySprite.play('reboundPost')
	
func update():
	Player.handlePhys()
	handleAnimations()
	Player.handleMovement()
	Player.handleCamera()
	
	if Input.is_action_pressed("ctrl_1"):
		if not Player.rebounding:
			Player.reboundQueued = true
	
	if Player.is_on_floor():
		if Player.rebounding:
			Player.rebounding = false
		Player.change_state(Player.state_machine.st_floor)
		
	if Input.is_action_just_pressed("ctrl_2") and not hasDashed \
	and theCooldown.time_left <= 0.0:
		doDash()
	
	if Player.invulnFrames <= 0.0 and isDashing:
		Player.delete_hitboxes('airdash')
		Player.plySprite.play('fall')
		isDashing = false
	
	if Player.is_on_wall() and isDashing:
		Player.delete_hitboxes('airdash')
		theCooldown = get_tree().create_timer(0.25)
		
		hasDashed = false
		isDashing = false
		Player.invulnFrames = 0.0
		Player.motion.y = -600
		Player.plySprite.play('wallkick')
		Player.play_char_sfx('Wallkick', 'Passo')
		
		if Player.is_wall_to_left():
			Player.plySprite.flip_h = true
			Player.motion.x = 500
		if Player.is_wall_to_right():
			Player.plySprite.flip_h = false
			Player.motion.x = -500

func handleAnimations():
	super.handleAnimations()
	if Player.jumping && Player.motion.y > 0:
		Player.plySprite.play('fall')

func doDash():
	Player.make_hitbox(Vector2(36, 8),
						Vector2(1.0, 5.8),
						Player.ATTACK_DMG_LVL['default'],
						800.0,
						105,
						'airdash')
	
	var flipped:bool = 	Input.is_action_pressed("ctrl_left") \
						or not Input.is_action_pressed("ctrl_right") \
						and Player.plySprite.flip_h
	
	Player.motion.y = 0
	if ((Player.motion.x < 800) and not flipped) \
	or ((Player.motion.x > -800) and flipped):
		Player.motion.x = -800 if flipped else 800
	else:
		Player.motion.x += -125 if flipped else 125
	
	Player.jumping = false
	Player.invulnFrames = 24.0
	isDashing = true
	hasDashed = true
	Player.plySprite.play('airDash')
	Player.play_sfx('Thok')

func exit_state():
	Player.delete_hitboxes('airdash')
	isDashing = false
	hasDashed = false
