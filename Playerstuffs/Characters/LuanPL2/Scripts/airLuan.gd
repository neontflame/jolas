extends "res://Playerstuffs/StateMachinery/airSt.gd"

func enter_state():
	Player.change_state(Player.state_machine.st_floor)
