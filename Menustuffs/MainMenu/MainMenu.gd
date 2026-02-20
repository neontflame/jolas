extends "res://Menustuffs/Submenu.gd"

var menuCoolios:Array = []
var menuNames:Array = []

func randomQuote():
	var quotes := [
		'bosta em lata',
		'como se fala akuma ao contrario',
		'musculão saltitoso',
		'QUAL É A CORRENTE MILAGROSA.',
		's saoo po\'\' n the AAAAsta wgo a',
		'*eu nao respondo, minha transformação em chiclete foi total*',
		'MEU SANTO PORPETONE !!',
		'o hawnt xinga o maujoa',
		'FALA PORTUGUES GATO DESGRAÇADO',
		'eu preciso lavar seu cerebro',
		'Insert shocking scene here',
		'sua mae nao sabe plantar um furico sequer',
		'dave',
		'Shii',
		'o queijo .',
		'bomba nuclear de bosta',
		'roubar o banco e tacar fogo em',
		'"Sir, have you been pissing tonight?"',
		'who up colorindo they textinho',
		'hihi quando',
		'lembra daquela vez que EU e o speed tentamos nao rir',
		'MINHA MAE É PARCIALMENTE PENDENDO A SER MENDIGA',
		'cara vai se fuder\ncom a porra do seu mr beast'
	]
	return quotes[randi_range(0, len(quotes) - 1)]
	
func _ready() -> void:
	$MenuCanvas/Quote.text = randomQuote()
	
	for child in $MenuCanvas/RightAnchor/Opts.get_children():
		menuCoolios.append(child)
	
	CoolMenu.maxSelected = len(menuCoolios)
	CoolMenu.blurAmount = 0.0
	CoolMenu.activeMusicLayers = 1
	
var optWidth := 253.0
func _process(delta: float) -> void:
	for menuOpt in menuCoolios:
		if menuCoolios[CoolMenu.curSelected] == menuOpt:
			menuOpt.play('active')
			menuOpt.position.x = lerp(menuOpt.position.x, -16.0, 0.2)
			menuOpt.self_modulate.a = 1
		else:
			menuOpt.play('inactive')
			menuOpt.position.x = lerp(menuOpt.position.x, 0.0, 0.2)
			menuOpt.self_modulate.a = 0.5
	
	if Input.is_action_just_pressed('ui_down'):
		CoolMenu.play_sfx('Tick')
		CoolMenu.curSelected = wrap(CoolMenu.curSelected + 1, 0, CoolMenu.maxSelected)
	if Input.is_action_just_pressed('ui_up'):
		CoolMenu.play_sfx('Tick')
		CoolMenu.curSelected = wrap(CoolMenu.curSelected - 1, 0, CoolMenu.maxSelected)
	
	if Input.is_action_just_pressed('ui_accept'):
		goToMenu(menuCoolios[CoolMenu.curSelected].name)

func goToMenu(menuName:String):
	CoolMenu.play_sfx('Go')
	match menuName:
		'jolar':
			GPStats.is_multiplayer = false
			change_self_scene("res://Menustuffs/SaveMenu/SaveMenu.tscn")
		'jolarCoop':
			GPStats.is_multiplayer = true
			change_self_scene("res://Menustuffs/SaveMenu/SaveMenu.tscn")
		'addons':
			change_self_scene("res://Menustuffs/AddonsMenu/AddonsMenu.tscn")
		_:
			CoolMenu.stop_sfx('Go')
			CoolMenu.play_sfx('Back')
	print(menuName)
