extends MobStatePattern

var gotFloored := false

func enter_state():
	Mob.isHurting = false
	pass
	
func update():
	Mob.handlePhys()
	
	if Mob.is_on_floor():
		if !gotFloored:
			Mob.velocity.y = 4
			gotFloored = true
	else:
		gotFloored = false
	
	if Mob.touchingPlayer:
		if Mob.touchedPlayer.attack:
			Mob.yeowch(Mob.touchedPlayer.attackStrength, (Mob.position.x > Mob.touchedPlayer.x))
		else:
			Mob.touchedPlayer.yeowch(Mob.strength, (Mob.position.x < Mob.touchedPlayer.position.x))
