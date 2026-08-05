extends StatePattern

func enter_state():
	Player.canDoCharge = false
	Player.isSpecialing = true
	Player.jumping = false
	Player.apply_player_gravity()
