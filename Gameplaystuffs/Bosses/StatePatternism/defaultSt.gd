extends BossStatePattern

var gotFloored:bool = false

func enter_state():
	Boss.isHurting = false
	pass
	
func update():
	Boss.handlePhys()
	Boss.handlePlyHits(true)
	
	if Boss.is_on_floor():
		if !gotFloored:
			Boss.velocity.y = 4
			gotFloored = true
	else:
		gotFloored = false
