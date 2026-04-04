extends Control

#region Opt coisos
var optName:String = ''
var optInternal:String = ''
var selected:bool = false
var id:int = 0
var curOpt:Variant = 0

var validOpts:Array = []
#endregion

var isLabel = false

var getMoused:bool = false

signal goToOptions

func makeIt(internalName:String, visibleName:String, coolId:int, optionery:Array, defaultValue:Variant):
	optName = visibleName
	
	optInternal = internalName
	id = coolId
	validOpts = optionery
	if OptionsUtils.preferences.has(optInternal):
		curOpt = OptionsUtils.preferences[optInternal]
	else:
		curOpt = defaultValue
		
	if optionery == []:
		isLabel = true
		id = -1
	setup()
	
func setup():
	if isLabel:
		$Title.visible = true
		$Option.visible = false
		$Title/TitleName.text = tr(optInternal)
		return
		
	$Option/OptName.text = tr(optInternal)
	
	mouse_entered.connect(is_moused)
	mouse_exited.connect(un_moused)
	
	$Option/OptChoice.visible = (validOpts != ['slider'])
	$Option/OptSlider.visible = (validOpts == ['slider'])
	
	if optInternal == 'keybinds':
		$Option/OptChoice.visible = false
	if validOpts == ['slider']:
		$Option/OptSlider.connect("drag_ended", youreDraggingIt)
		$Option/OptSlider.value = float(curOpt)
	else:
		changeThing(0)

func _process(delta: float) -> void:
	$bg.self_modulate.a = lerp($bg.self_modulate.a,
							(0.75 if selected else 0.4),
							0.2)
	
	if selected:
		if Input.is_action_just_pressed("ui_delete"):
			revertThing()
		if validOpts == ['slider']:
			if Input.is_action_pressed("ui_right"):
				$Option/OptSlider.value += 0.02
			if Input.is_action_pressed("ui_left"):
				$Option/OptSlider.value -= 0.02
		else:
			if Input.is_action_just_pressed("ui_right") || Input.is_action_just_pressed("ui_click") || Input.is_action_just_pressed("ui_accept"):
				changeThing(1)
			if Input.is_action_just_pressed("ui_left"):
				changeThing(-1)
	else:
		$Option/OptSlider.release_focus()

func is_moused():
	CoolMenu.curSelected = id
	getMoused = true

func un_moused():
	CoolMenu.curSelected = -1
	getMoused = false

func changeThing(howMany:int):
	curOpt = wrap(int(curOpt) + howMany, 0, len(validOpts))
	if optInternal != 'keybinds':
		$Option/OptChoice.text = '< ' + tr(validOpts[curOpt]) + ' >'
		OptionsUtils.preferences[optInternal] = curOpt
	if optInternal == 'keybinds':
		goToOptions.emit()
	CoolMenu.play_sfx('Tick')

func revertThing():
	for optThing in OptionsUtils.coolOptiones:
		if optThing[0] == optInternal:
			curOpt = optThing[3]
			if validOpts == ['slider']: $Option/OptSlider.value = curOpt
			else: $Option/OptChoice.text = '< ' + tr(validOpts[curOpt]) + ' >'
			CoolMenu.play_sfx('Back')
	OptionsUtils.preferences[optInternal] = curOpt

func youreDraggingIt(changery:bool):
	CoolMenu.play_sfx('Go')

func sliderDraggest(value: float) -> void:
	CoolMenu.play_sfx('Tick')
	OptionsUtils.preferences[optInternal] = $Option/OptSlider.value
