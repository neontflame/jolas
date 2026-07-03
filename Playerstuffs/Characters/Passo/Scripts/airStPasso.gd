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
		Player.make_hitbox(Vector2(-4, 0),
							Vector2(6.58, 6.255),
							Player.ATTACK_DMG_LVL['rebound'],
							1000.0,
							135.0,
							'rebound')
		Player.play_char_sfx('ReboundYI', 'Passo')
		Player.plySprite.play('reboundPost')
	
func update():
	Player.handlePhys()
	handleAnimations()
	Player.handleMovement()
	Player.handleCamera()
	Player.apply_player_gravity()
	
	if Input.is_action_just_pressed("ctrl_1"):
		if not Player.rebounding and not Player.reboundQueued:
			Player.play_sfx("InstaShield")
			Player.reboundQueued = true
			Player.rebound_ready_animation(10.0)
	
	if Player.is_on_floor():
		if Player.rebounding:
			Player.rebounding = false
		Player.change_state(Player.state_machine.st_floor)
	
	if not Player.rebounding:
		Player.delete_hitboxes('rebound')
	
	if Input.is_action_just_pressed("ctrl_2") and not hasDashed \
	and theCooldown.time_left <= 0.0:
		doDash()
	
	if Player.invulnFrames <= 0.0 and isDashing:
		Player.delete_hitboxes('airdash')
		# Player.plySprite.play('fall')
		isDashing = false
	
	if Player.is_on_wall() and isDashing:
		Player.delete_hitboxes('airdash')
		theCooldown = get_tree().create_timer(0.25, false)
		
		hasDashed = false
		isDashing = false
		Player.invulnFrames = 0.0
		Player.motion.y = -600
		Player.plySprite.play('wallkick')
		Player.play_char_sfx('Wallkick', 'Passo')
		
		if Player.is_wall_to_left():
			check_ce_kill()
			Player.plySprite.skew = 0.0
			Player.motion.x = 500
			Player.plySprite.flip_h = true
		if Player.is_wall_to_right():
			check_ce_kill()
			Player.plySprite.skew = 0.0
			Player.motion.x = -500
			Player.plySprite.flip_h = false

func handleAnimations():
	super.handleAnimations()
	if Player.motion.y > 0 and not isDashing:
		Player.plySprite.play('fall')

func doDash():
	Player.rebounding = false
	Player.make_hitbox(Vector2(36, 8),
						Vector2(1.0, 5.8),
						Player.ATTACK_DMG_LVL['default'],
						800.0,
						105,
						'airdash')
	
	var flipped: bool = Input.is_action_pressed("ctrl_left") \
						or not Input.is_action_pressed("ctrl_right") \
						and Player.plySprite.flip_h
	
	Player.motion.y = 0
	if ((Player.motion.x < 800) and not flipped) \
	or ((Player.motion.x > -800) and flipped):
		Player.motion.x = -800 if flipped else 800
	else:
		Player.motion.x += -155 if flipped else 155
	
	if Player.motion.x > 0.0:
		Player.plySprite.flip_h = false
	else:
		Player.plySprite.flip_h = true
	cool_effect(Player.plySprite.flip_h)
	Player.jumping = false
	Player.invulnFrames = 24.0
	isDashing = true
	hasDashed = true
	Player.plySprite.play('airDash')
	Player.play_sfx('Thok')

func exit_state():
	Player.delete_hitboxes('airdash')
	Player.delete_hitboxes('rebound')
	isDashing = false
	hasDashed = false

var ce_tween: Tween

func cool_effect(is_flipped: bool = false):
	var multiplier = -1.0 if is_flipped else 1.0
	var initial_value = 0.75 * sign(multiplier)
	Player.plySprite.skew = initial_value
	check_ce_kill() 
	ce_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	ce_tween.tween_property(Player.plySprite, "skew", 0.0, 0.5)

func check_ce_kill():
	if ce_tween and ce_tween.is_valid():
		ce_tween.kill()
