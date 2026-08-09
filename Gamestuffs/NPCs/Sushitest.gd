extends NPC

func interaction(able:bool):
	if able:
		$BolhaDeFala.textUndertales()
		$BolhaDeFala.visible = true
	else:
		$BolhaDeFala.visible = false
		$BolhaDeFala.noUndertales()
