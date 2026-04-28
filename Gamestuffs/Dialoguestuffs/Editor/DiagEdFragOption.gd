extends Control
class_name DiagEdFragOption

var textCool:String = ""
var diagFilename:String = ""

func _enter_tree() -> void:
	$LineEdit.text = textCool
	$LineEdit2.text = diagFilename

#ooooooough preguiça
func _on_line_edit_text_changed(new_text: String) -> void:
	textCool = new_text

func _on_line_edit_2_text_changed(new_text: String) -> void:
	diagFilename = new_text
