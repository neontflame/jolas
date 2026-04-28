extends Control
class_name DiagEdFragment

signal delete(frag:DiagEdFragment)
signal moveDown(frag:DiagEdFragment)
signal moveUp(frag:DiagEdFragment)

@export var id:int = 1
var isChoice:bool = false

@export var choiceContainer:VBoxContainer

func setup(diag:Dictionary):
	$LineEditChar.text = diag["char"]
	$LineEditEmotion.text = diag["mood"]
	$CheckButton.button_pressed = diag.has("choice")
	if diag.has("choice"):
		for choi in diag["choice"]:
			var newThingie = load("res://Gamestuffs/Dialoguestuffs/Editor/DiagEdFragOption.tscn").instantiate()
			newThingie.textCool = choi[0]
			newThingie.diagFilename = choi[1]
			choiceContainer.add_child(newThingie)
	elif diag.has("line"):
		$ifDiag/TextEdit.text = diag["line"]
	
func _physics_process(delta: float) -> void:
	isChoice = $CheckButton.button_pressed
	$ifDiag.visible = !isChoice
	$ifChoice.visible = isChoice

func makeJson():
	var dic:Dictionary = {}
	dic["char"] = $LineEditChar.text
	dic["mood"] = $LineEditEmotion.text
	if isChoice:
		var coolArraye = []
		for kid in choiceContainer.get_children():
			coolArraye.append([kid.textCool, kid.diagFilename])
		dic["choice"] = coolArraye
	else:
		dic["line"] = $ifDiag/TextEdit.text
	return dic

func _on_add_button_pressed() -> void:
	var newThingie = load("res://Gamestuffs/Dialoguestuffs/Editor/DiagEdFragOption.tscn").instantiate()
	choiceContainer.add_child(newThingie)

func _on_delete_button_pressed() -> void:
	if choiceContainer.get_child_count() > 0:
		choiceContainer.remove_child(
			choiceContainer.get_child(
				choiceContainer.get_child_count() - 1
			)
		)

func _on_up_button_pressed() -> void:
	moveUp.emit(self)

func _on_down_button_pressed() -> void:
	moveDown.emit(self)

func _on_delete_this_shit_button_pressed() -> void:
	delete.emit(self)
