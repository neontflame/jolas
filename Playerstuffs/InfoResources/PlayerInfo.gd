@tool
extends Resource
class_name PlayerInfo

@export var name: String = "Pers, o Nagem"
@export_multiline var desc: String = "esse e meu oc dos especulativos ele tem uma habilidade que mata todo mundo"

#region coisos de habilidade
@export var ability: Array = []

@export_tool_button("Adicionar string", "Add") var stringAdd = _add_string

@export_tool_button("Adicionar habilidade", "Add") var abilityAdd = _add_ability

func _add_string() -> void:
	ability.append("")
	emit_changed()
	notify_property_list_changed()

func _add_ability() -> void:
	ability.append(PlayerInfoAbility.new())
	emit_changed()
	notify_property_list_changed()
#endregion

@export var locked:bool = false
