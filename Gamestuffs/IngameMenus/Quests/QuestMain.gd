extends Sprite2D

var isActive:bool = true
@export var questContainer:VBoxContainer
@export var infoLabel:Label

func _enter_tree() -> void:
	infoLabel.text = tr('quests_info') % [len(QuestUtils.clearedQuests), len(QuestUtils.assignedQuests)]
	for kid in questContainer.get_children():
		kid.queue_free()
	
	var idcool:int = 0
	if len(QuestUtils.assignedQuests) > 0:
		$questWarn.visible = false
	for quest in QuestUtils.assignedQuests:
		var newQuestle = load("res://Gamestuffs/IngameMenus/Quests/QuestThingie.tscn").instantiate()
		questContainer.add_child(newQuestle)
		newQuestle.renderQuest(quest)
		newQuestle.id = idcool
		idcool += 1
	CoolMenu.maxSelected = len(QuestUtils.assignedQuests)

func _process(delta: float) -> void:
	for coolquest in questContainer.get_children():
		if CoolMenu.curSelected != -1:
			coolquest.selected = (coolquest.id == CoolMenu.curSelected)
		else:
			coolquest.selected = false
	
	if isActive:
		if Input.is_action_just_pressed("ui_up"):
			CoolMenu.curSelected = wrap(CoolMenu.curSelected + 1, 0, CoolMenu.maxSelected)
		if Input.is_action_just_pressed("ui_down"):
			CoolMenu.curSelected = wrap(CoolMenu.curSelected - 1, 0, CoolMenu.maxSelected)
