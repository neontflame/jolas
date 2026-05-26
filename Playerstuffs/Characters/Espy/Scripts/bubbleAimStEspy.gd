extends StatePattern

var deaccelerate_tween: Tween
var bubble_tween: Tween

func enter_state():
	if Player.is_on_floor():
		Player.motion.y = -200.0
	Player.plySprite.play("bubbleIn")
	tween_dat_shit()

func update():
	if Input.is_action_just_released("ctrl_2"):
		release_espy()

func exit_state():
	kill_tweens(deaccelerate_tween)
	kill_tweens(bubble_tween)

func release_espy():
	bubble_pop()
	Player.change_state(Player.state_machine.st_air)

#region Tween Stuff
func tween_dat_shit():
	kill_tweens(deaccelerate_tween)
	kill_tweens(bubble_tween)
	
	# tween de posicao
	deaccelerate_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	deaccelerate_tween.tween_property(Player, "motion", Vector2.ZERO, 1.0)
	
	# tween da bolha aparecendo
	Player.bolha_sprite.scale = Vector2.ZERO
	Player.bolha_sprite.modulate.a = 1.0
	bubble_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	bubble_tween.tween_property(Player.bolha_sprite, "scale", Vector2.ONE, 1.0)

func bubble_pop():
	kill_tweens(bubble_tween)
	bubble_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	bubble_tween.tween_property(Player.bolha_sprite, "scale", Vector2(2.0, 2.0), 0.5)
	bubble_tween.parallel().tween_property(Player.bolha_sprite, "modulate:a", 0.0, 0.5)

func kill_tweens(which: Tween):
	if which and which.is_valid():
		which.kill()
#endregion
