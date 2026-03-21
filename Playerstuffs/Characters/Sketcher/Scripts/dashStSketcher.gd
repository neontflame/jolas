extends StatePattern

var homing := false

func enter_state():
	Player.ELECTRICITY -= Player.ELEC_USAGE['dash']
	Player.dashLine.clear_points()
	Player.boostLine.visible = false
	Player.dashLine.visible = true
	Player.plySprite.play('dash')
	Player.player_collisions.disabled = true
	Player.get_node('CollisionShape2D2').disabled = true
	Player.get_node('DashColl').disabled = false
	
	Player.play_char_sfx('Homing', 'Sketcher')

	Player.jumping = false
	Player.make_hitbox(	Vector2(0.0, 0.0),
						Vector2(4.945, 4.945),
						Player.ATTACK_DMG_LVL['dash'],
						900,
						315,
						'dash')
	# nao achou nada pra fazer homing attack
	if find_closest():
	# achou algo pra fazer homing attack
		# Full Homers
		homing = true
		var tweenMe = create_tween()
		Player.plySprite.rotation = Player.global_position.angle_to_point(find_closest().global_position)
		tweenMe.tween_property(Player, "global_position", find_closest().global_position + Vector2(0, -25), 0.1)
		tweenMe.tween_callback(
		func():
			Player.plySprite.rotation = 0
			Player.global_position.y -= 100
			Player.motion = Vector2(0.0, -600.0)
			Player.change_state(Player.state_machine.st_air)
			Player.plySprite.play('vault')
			Player.canDash = true
		)
	else:
		# No Homers
		homing = false
		Player.plySprite.rotation = 0
		Player.up_direction = Vector2(0, -1)
		Player.motion.y = 0
		if Input.is_action_pressed("ctrl_left") \
		or not Input.is_action_pressed("ctrl_right") and Player.plySprite.flip_h:
			Player.plySprite.flip_h = true
			Player.motion.x = -1600
		else:
			Player.plySprite.flip_h = false
			Player.motion.x = 1600
		await get_tree().create_timer(0.25).timeout
		if not Input.is_action_pressed("ctrl_left") and not Input.is_action_pressed("ctrl_right"):
			Player.motion.x = Player.motion.x / 2
		Player.change_state(Player.state_machine.st_floor)
		Player.plySprite.play('jump')

func update():
	if not homing:
		# Player.handlePhys()
		Player.handleCamera()

func exit_state():
	Player.player_collisions.disabled = false
	Player.get_node('CollisionShape2D2').disabled = true
	Player.get_node('DashColl').disabled = true
	Player.delete_hitboxes('dash')
	Player.dashLine.visible = false

# fonte: https://forum.godotengine.org/t/help-finding-nearest-object-and-working-out-the-proper-code-i-just-realized-i-need-this-done-in-the-next-six-days/57537
func find_closest() -> Variant:
	var mobbies = Player.homingArea.get_overlapping_bodies()
	var lowest_distance = INF    # Initialized as infinity to avoid unintended behaviour at large distances
	var closest_mob
	for mob in mobbies:
		if mob is MobObject:
			if mob.isDead: continue
			var distance = mob.global_position.distance_squared_to(Player.global_position)
			# Check whether the distance to the animal is lower
			# than the previously checked animals
			if distance < lowest_distance:
				closest_mob = mob       # Set this animal as the closest animal
				lowest_distance = distance    # Update the lowest distance found

	# This is an if-statement that evaluates whether an animal was found
	# It will usually only run if there are no valid animal instances
	if !is_instance_valid(closest_mob) or lowest_distance == INF:
		return null
	return closest_mob
