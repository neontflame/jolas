extends "res://Levelstuffs/Mobs/StatePatternism/defaultSt.gd"

func update():
	super.update()
	
	if Mob.detectingPlayer:
		if Mob.position.x < GPStats.charObject.position.x:
			Mob.inputSimulation(1, 0)
		elif Mob.position.x > GPStats.charObject.position.x:
			Mob.inputSimulation(-1, 0)
		
		if Mob.position.y > GPStats.charObject.position.x:
			Mob.inputSimulation(0, -1)
	else:
		Mob.inputSimulation(0, 0)
