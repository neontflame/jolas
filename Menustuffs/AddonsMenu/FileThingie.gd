extends Control

var filename:String = ''
var selected:bool = false
var id:int = 0
var getMoused:bool = false

func setup():
	$Label.text = filename
	if filename.ends_with('pck'):
		$fileicon.play('pck')
	elif filename.ends_with('/'):
		$fileicon.play('folder')
	else:
		$fileicon.play('default')
	
	mouse_entered.connect(is_moused)
	mouse_exited.connect(un_moused)

func _process(delta: float) -> void:
	$bg.self_modulate.a = lerp($bg.self_modulate.a,
							(0.75 if selected else 0.4),
							0.2)

func is_moused():
	CoolMenu.curSelected = id
	getMoused = true

func un_moused():
	getMoused = false
