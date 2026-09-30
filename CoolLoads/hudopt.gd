extends Node

func _init() -> void:
	var ptbr = TranslationServer.get_translation_object("pt_BR")
	var en = TranslationServer.get_translation_object("en_US")
	
	ptbr.add_message("sonicopts", "Opções do SRB2Sonic")
	ptbr.add_message("srb2Hud", "HUD do SRB2")
	
	en.add_message("sonicopts", "SRB2Sonic Options")
	en.add_message("srb2Hud", "SRB2 HUD")
	
	OptionsUtils.coolOptiones.append_array([
		['sonicopts', 'Opções do SRB2Sonic', [], 0, -1],
			['srb2Hud', 'Hud do SRB2', ['opt_no', 'opt_yes'], 1, -1]
	])
