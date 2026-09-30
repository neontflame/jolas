extends Control

var modId:String = ''
var selected:bool = false
var applied:bool = false
var id:int = 0
var getMoused:bool = false

var canMouse:bool = true

func setup():
	var modInfo:Dictionary = ModUtils.get_mod_info(modId)
	$Label.text = modInfo.name
	$AuthLabel.text = modInfo.author
	
	mouse_entered.connect(is_moused)
	mouse_exited.connect(un_moused)

func _process(_delta: float) -> void:
	
	if applied:
		$bg.texture.gradient.set_color(0, Color.GOLD)
		$Label.self_modulate.a = 0.5
	else:
		$bg.texture.gradient.set_color(0, Color.BLACK)
		$Label.self_modulate.a = 1
		
	$bg.modulate.a = lerp($bg.modulate.a,
							(0.75 if selected else 0.4),
							0.2)

func is_moused():
	if not canMouse: return
	CoolMenu.curSelected = id
	getMoused = true

func un_moused():
	if not canMouse: return
	CoolMenu.curSelected = -1
	getMoused = false
