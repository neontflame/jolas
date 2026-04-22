extends StatePattern
var usingMouse:bool = false

func enter_state():
	# print('RRRRRRRRROCKET')
	usingMouse = false
	Player.rocketIndicator.visible = true

func update():
	Player.handlePhys()
	Player.handleCamera()
	handleRocketAnims()
	
	Player.rocketPos = Player.get_global_mouse_position()

	if Player.rocketAngle < 0:
		Player.rocketAngle += 360
		
	# if Player.rocketPos.x > Player.position.x:
	if Player.rocketAngle < 270 && Player.rocketAngle > 90:
		Player.plySprite.flip_h = true
	#if Player.rocketPos.x < Player.position.x:
	else:
		Player.plySprite.flip_h = false
		
	
	var addedPos := Vector2(75, 60) * Vector2.from_angle(deg_to_rad(Player.rocketAngle))
	
	if usingMouse:
		Player.rocketAngle = rad_to_deg(Player.position.angle_to_point(Player.rocketPos))
	else:
		var coolInputs = ["ctrl_left", "ctrl_down", "ctrl_up", "ctrl_right"]
		for inp in coolInputs:
			if Input.is_action_pressed(inp):
				Player.rocketAngle = rad_to_deg(Input.get_vector("ctrl_left", "ctrl_right", "ctrl_up", "ctrl_down").angle())

	if Input.is_action_just_pressed("ctrl_1") && Player.ammo > 0:
		Player.ammo -= 1
		MapUtils.spawn_object('Missile', Player.position + addedPos, 'Default',
			{	
			"direction": Vector2.from_angle(deg_to_rad(Player.rocketAngle)),
			"speed": 20.0 + abs(Player.motion.x * 0.005),
			"rotation": deg_to_rad(Player.rocketAngle),
			"power": GPStats.level,
			"owner_id": Player.playerID
			}
		)

		
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
	var sushiRocketAngle = fmod(Player.rocketAngle - rad_to_deg(Player.practicalAngle) + 7, 360.0)
	var sushiFrame = round(fmod(sushiRocketAngle, 360.0)/22.5) / 2
	if sushiFrame < 0:
		sushiFrame = abs(sushiFrame) + 4
	if sushiFrame > 7:
		sushiFrame -= 8
	print(sushiFrame)
	Player.plySprite.play('rocketLauncher', 0)
	Player.plySprite.set_frame(sushiFrame) # codigo com alma
	var addedAngle := 90
	Player.camOffset = Vector2(
						sin(deg_to_rad(Player.rocketAngle + addedAngle)) * 100,
						cos(deg_to_rad(Player.rocketAngle + addedAngle)) * -100
						)
	pass

func exit_state():
	Player.rocketIndicator.visible = false
	Player.camOffset = Vector2.ZERO
	
func _input(event):
	if event is InputEventMouseMotion:
		usingMouse = true
