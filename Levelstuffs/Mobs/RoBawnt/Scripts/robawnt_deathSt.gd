extends "res://Levelstuffs/Mobs/StatePatternism/deathSt.gd"

func enter_state():
	Mob.play_mob_sfx('robawnt_vo_dead', 'RoBawnt')
