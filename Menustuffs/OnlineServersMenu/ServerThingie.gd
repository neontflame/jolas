extends Control
class_name ServerThingie

var id:int = 0
var selected:bool = false
var metadata:Dictionary = {}

func setup(_id:int, dic:Dictionary):
	id = _id
	metadata = dic
	$Ip.text = dic["ip"]
	$nomecoiso.text = dic["nome"]
	if dic.has("mods") && dic["mods"][0] != "":
		$Indicator.text = "M"
		$Indicator.add_theme_color_override("font_color", Color("ff805b"))
	else:
		$Indicator.text = "V"
		$Indicator.add_theme_color_override("font_color", Color("77dcff"))
	
	mouse_entered.connect(is_moused)
	mouse_exited.connect(un_moused)

func _process(delta: float) -> void:
	$bg.self_modulate.a = lerp($bg.self_modulate.a,
							(0.75 if selected else 0.4),
							0.2)
							
func is_moused():
	CoolMenu.curSelected = id

func un_moused():
	CoolMenu.curSelected = -1
