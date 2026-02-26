extends "res://Playerstuffs/Characters/Sushi/Scripts/rocketStSushi.gd"

func enter_state():
	super.enter_state()
	print('(floor)')
	Player.motion.y = 4

func update():
	super.update()
	Player.motion.x = Player.motion.x * 0.975
	if !Player.is_on_floor():
		Player.change_state(Player.state_machine.st_rocket_air)
