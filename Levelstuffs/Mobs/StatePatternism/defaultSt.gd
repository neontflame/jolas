extends MobStatePattern

var gotFloored:bool = false

func enter_state():
	Mob.isHurting = false
	pass
	
func update():
	Mob.handlePhys()
	Mob.handlePlyHits(true)
	
	if Mob.is_on_floor():
		if !gotFloored:
			Mob.velocity.y = 4
			gotFloored = true
	else:
		gotFloored = false
