extends HeadsUpDisplay
class_name SRB2HeadsUpDisplay

@export var inventoryText:Label
@export var questText:Label
@export var comboSprite:AnimatedSprite2D
@export var comboLabel:Label
@export var levelCharName:Label

func _ready() -> void:
	super._ready()
	var replacies = [
		["SRB2", ""],
		["Fucking ", "Fkn."]
	]
	var theFucknName:String = GameUtils.get_char_info(GPStats.char)["name"]
	for rep in replacies:
		theFucknName = theFucknName.replace(rep[0], rep[1])
	levelCharName.text = theFucknName.split(" ", false)[0]
func _process(delta: float) -> void:
	super._process(delta)
	
	var hueShifty = fmod((GPStats.level - 1) * 7.5, 100.0) / 100.0
	levelCharName.material.set_shader_parameter('shift_hue', hueShifty)
	
	inventoryText.text = str(len(InventoryUtils.inventory))
	questText.text = str(len(QuestUtils.assignedQuests))

func show_combo_hud():
	comboSprite.play("default")
	comboLabel.text = GeneralUtils.display_number(GPStats.charObject.combo)

func hide_combo_hud():
	comboSprite.play("none")
	comboLabel.text = GeneralUtils.display_number(GPStats.charObject.combo)
