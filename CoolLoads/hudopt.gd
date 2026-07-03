extends Node

func _init() -> void:
	OptionsUtils.coolOptiones.append_array([
		['sonicopts', 'Opções do SRB2Sonic', [], 0, -1],
			['srb2Hud', 'Hud do SRB2', ['opt_no', 'opt_yes'], 1, -1]
	])
