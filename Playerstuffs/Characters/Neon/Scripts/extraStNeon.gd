extends StatePattern

func enter_state():
	print('state custom funciona')
	
	if Player.is_on_floor():
		Player.change_state(Player.state_machine.st_floor)
	else:
		Player.change_state(Player.state_machine.st_air)

func exit_state():
	print('adios')
