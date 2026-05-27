extends StatePattern

var deaccelerate_tween: Tween
var bubble_tween: Tween
var arrow_tween: Tween

func enter_state():
	if Player.is_on_floor():
		Player.motion.y = -200.0
	Player.plySprite.play("bubbleIn")
	Player.plySprite.flip_h = false
	Player.play_char_sfx("s3BubbleShield", "Espy")
	tween_dat_shit()

func update():
	if deaccelerate_tween.finished:
		Player.apply_player_gravity(5.0)
	
	Player.practicalAngle = lerp_angle(Player.practicalAngle, 0.0, 0.1)
	if Input.is_action_pressed("ctrl_2"):
		Player.bubble_aim_camera()
	Player.rotate_arrow_based_on_input()
	Player.setaralho.rotation = lerp_angle(Player.setaralho.rotation, Player.bubble_aim.angle(), 0.25)
	
	if Input.is_action_just_released("ctrl_2"):
		release_espy()

func exit_state():
	kill_tweens(deaccelerate_tween)
	bubble_pop()

func release_espy():
	Player.make_hitbox(Vector2.ZERO,
		Vector2(6.0, 6.0),
		Player.ATTACK_DMG_LVL['default'],
		0.0,
		0.0,
		"bubble"
	)
	Player.play_char_sfx("balloonPop", "Espy")
	Player.motion = 2000.0 * Player.bubble_aim.normalized()
	Player.bubble_blasted = true
	Player.change_state(Player.state_machine.st_air)

#region Tween Stuff
func tween_dat_shit():
	# tween de posicao
	kill_tweens(deaccelerate_tween)
	deaccelerate_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	deaccelerate_tween.tween_property(Player, "motion", Vector2.ZERO, 1.0)
	
	# tween da bolha aparecendo
	kill_tweens(bubble_tween)
	Player.bolha_sprite.scale = Vector2.ZERO
	Player.bolha_sprite.modulate.a = 1.0
	bubble_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	bubble_tween.tween_property(Player.bolha_sprite, "scale", Vector2.ONE, 1.0)
	
	# tween da seta
	kill_tweens(arrow_tween)
	Player.setaralho.modulate.a = 0.0
	arrow_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	arrow_tween.tween_property(Player.setaralho, "modulate:a", 1.0, 0.5)

func bubble_pop():
	kill_tweens(bubble_tween)
	bubble_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	bubble_tween.tween_property(Player.bolha_sprite, "scale", Vector2(2.0, 2.0), 0.5)
	bubble_tween.parallel().tween_property(Player.bolha_sprite, "modulate:a", 0.0, 0.5)
	
	kill_tweens(arrow_tween)
	arrow_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	arrow_tween.tween_property(Player.setaralho, "modulate:a", 0.0,0.5)

func kill_tweens(which: Tween):
	if which and which.is_valid():
		which.kill()
#endregion
