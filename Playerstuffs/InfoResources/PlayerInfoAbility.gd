extends Resource
class_name PlayerInfoAbility

@export var name:String = "Habilidade"
@export var color:Color = Color.YELLOW
@export_multiline var instructions:String = "Sei la mano aperta ctrl_2"

func _to_string() -> String:
	return "[color=#%s]%s[/color]: %s" % [color.to_html(), name, GeneralUtils.text_replacery(instructions)]
