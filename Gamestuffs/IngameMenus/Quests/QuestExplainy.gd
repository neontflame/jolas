extends Sprite2D

func renderQuest(questName:StringName):
	$QuestName.text = QuestUtils.get_info(questName)['name']
	$QuestContent.text = QuestUtils.get_info(questName)['desc']
	$QuestReward.text = '[color=990000][b]Recompensa:[/b][/color] '
	if QuestUtils.get_info(questName)['xpReward'] > 0:
		$QuestReward.text += "+%s xp" % QuestUtils.get_info(questName)['xpReward']
	else:
		$QuestReward.text += 'nada lmfao'
