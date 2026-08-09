extends NPC

func playDialogue():
	if QuestUtils.assignedQuests.has('queixoEAsJolas'):
		if InventoryUtils.has_item_in_inventory('jola', 5):
			JolasGame.instance.playDialogue('queixoJolaConcluido')
		else:
			JolasGame.instance.playDialogue('queixoJolaPendente')
	elif QuestUtils.clearedQuests.has('queixoEAsJolas'):
		JolasGame.instance.playDialogue('queixoJolaConcluido')
	else:
		JolasGame.instance.playDialogue(dialogue)
