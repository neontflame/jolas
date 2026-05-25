extends "res://Gamestuffs/NPCs/NPC.gd"

func playDialogue():
	var extraCoiso:String = (('.%s' % GPStats.char) if dialogoPorChar else '')
	if QuestUtils.assignedQuests.has('queixoEAsJolas'):
		if InventoryUtils.has_item_in_inventory('jola', 5):
			JolasGame.instance.playDialogue('queixoJolaConcluido')
		else:
			JolasGame.instance.playDialogue('queixoJolaPendente')
	else:
		JolasGame.instance.playDialogue(dialogue + extraCoiso)
