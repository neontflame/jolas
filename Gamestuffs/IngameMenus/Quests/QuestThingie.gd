extends Control

var selected:bool = false
var id:int = 0
var getMoused:bool = false

func setup():
	mouse_entered.connect(is_moused)
	mouse_exited.connect(un_moused)

func renderQuest(questName:StringName):
	$QuestName.text = QuestUtils.get_info(questName)['name']
	$QuestRoom.text = QuestUtils.get_info(questName)['room']
	$QuestIcon.texture = QuestUtils.get_icon(QuestUtils.get_info(questName)['icon'])

func _process(_delta: float) -> void:
	$bg.self_modulate.a = lerp($bg.self_modulate.a,
							(0.5 if selected else 0.0),
							0.2)

func is_moused():
	CoolMenu.curSelected = id
	getMoused = true

func un_moused():
	CoolMenu.curSelected = -1
	getMoused = false
