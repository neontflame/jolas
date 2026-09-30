extends "res://Gameplaystuffs/Mobs/StatePatternism/deathSt.gd"

func enter_state():
	super.enter_state()
	Mob.play_mob_sfx('grunt-kill', 'Sandler')
