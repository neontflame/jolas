extends HeadsUpDisplay
class_name SRB2HeadsUpDisplay

@export var inventoryText:Label
@export var questText:Label
@export var comboSprite:AnimatedSprite2D
@export var comboLabel:Label
@export var levelCharName:Label

@export var oldHpBar:NinePatchRect

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

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	var hueShifty = fmod((GPStats.level - 1) * 7.5, 100.0) / 100.0
	levelCharName.material.set_shader_parameter('shift_hue', hueShifty)
	
	inventoryText.text = str(len(InventoryUtils.inventory))
	questText.text = str(len(QuestUtils.assignedQuests))


func hpXpHandler():
	if !GPStats.charObject: return
	hpText.text = "%s/%s" % [GeneralUtils.display_number(GPStats.charObject.hp), str(GPStats.maxHP)]
	xpText.text = "%s/%s" % [GeneralUtils.display_number(GPStats.xp), (GPStats.level * GPStats.lvLimit)]
	# testLabel.text = 'vel x: ' + GeneralUtils.display_number(GPStats.charObject.motion.x) + ' | vel y: ' + GeneralUtils.display_number(GPStats.charObject.motion.y)

	# treco tinha quebrado aqui ai eu fui ver o que era
	# eu esqueci de colocar um .0 depois do 144
	oldHpBar.size.x = lerp(oldHpBar.size.x, 
			float(144.0 / GPStats.maxHP) * GPStats.charObject.hp,
			0.5)

func show_combo_hud():
	comboSprite.play("default")
	comboLabel.text = GeneralUtils.display_number(GPStats.charObject.combo)

func hide_combo_hud():
	comboSprite.play("none")
	comboLabel.text = GeneralUtils.display_number(GPStats.charObject.combo)
