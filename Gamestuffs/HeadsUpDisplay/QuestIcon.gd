extends Sprite2D

func _enter_tree() -> void:
	$RichTextLabel.bbcode_enabled = true
	$RichTextLabel.text = GeneralUtils.text_replacery("ctrl_quests")

func _process(delta: float) -> void:
	$QuestCount.visible = (len(QuestUtils.assignedQuests) > 0)
	$QuestCount/Label.text = str(len(QuestUtils.assignedQuests))
