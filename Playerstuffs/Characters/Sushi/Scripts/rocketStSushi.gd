extends StatePattern

func enter_state():
	print('RRRRRRRRROCKET')

func update():
	Player.handlePhys()
	Player.handleCamera()
	handleRocketAnims()
	
	Player.rocketPos = Player.get_global_mouse_position()
	
	if Player.rocketPos.x > Player.position.x:
		Player.plySprite.flip_h = false
	if Player.rocketPos.x < Player.position.x:
		Player.plySprite.flip_h = true
		
	Player.rocketAngle = rad_to_deg(Player.position.angle_to_point(Player.rocketPos))
	if Player.rocketAngle < 0:
		Player.rocketAngle += 360
	
	var addedPos := Vector2(75, 60) * Vector2.from_angle(deg_to_rad(Player.rocketAngle))
	
	if Input.is_action_just_pressed("ctrl_1") && Player.ammo > 0:
		Player.ammo -= 1
		var missile = MapUtils.spawn_object('Missile', Player.position + addedPos, 'Sushi')
		missile.launch(
			Vector2.from_angle(deg_to_rad(Player.rocketAngle)),
			20.0 + abs(Player.motion.x * 0.005)
		)
		missile.rotation = deg_to_rad(Player.rocketAngle)
		missile.missileOwner = Player
		
	if Input.is_action_just_released("ctrl_2"):
		goBack()
	pass

func goBack():
	Player.camOffset = Vector2.ZERO
	if Player.is_on_floor():
		Player.change_state(Player.state_machine.st_floor)
	else:
		Player.change_state(Player.state_machine.st_air)
		
func handleRocketAnims():
	var sushiRocketAngle = fmod(Player.rocketAngle - rad_to_deg(Player.practicalAngle) + 15, 360.0)
	Player.plySprite.play('rocketLauncher', 0)
	Player.plySprite.set_frame(round(fmod(sushiRocketAngle, 360.0)/22.5) / 2) # codigo com alma
	var addedAngle := 90
	Player.camOffset = Vector2(
						sin(deg_to_rad(Player.rocketAngle + addedAngle)) * 100,
						cos(deg_to_rad(Player.rocketAngle + addedAngle)) * -100
						)
	pass
