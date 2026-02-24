extends Control

#region Key coisos
var optName:String = ''
var optInternal:String = ''
var selected:bool = false
var id:int = 0
var selectCooldown:int = 0
#endregion

var getMoused:bool = false

signal keyingBinds
signal noBinds

func makeIt(internalName:String, visibleName:String, coolId:int):
	optName = visibleName
	
	optInternal = internalName
	id = coolId
	setup()
	
func setup():
	selectCooldown = 0
	set_process_unhandled_input(false)
	$Idk/OptName.text = optName
	
	mouse_entered.connect(is_moused)
	mouse_exited.connect(un_moused)
	
	updateMyStuff()

func _process(delta: float) -> void:
	if selectCooldown > 0:
		selectCooldown -= 1
		
	$bg.self_modulate.a = lerp($bg.self_modulate.a,
							(0.75 if selected else 0.4),
							0.2)
	
	if selected:
		if Input.is_action_just_pressed("ui_click") || Input.is_action_just_pressed("ui_accept"):
			if !InputOptionsMenu.choosingKeybind && selectCooldown <= 0:
				triggerKeybindUpdate()

func is_moused():
	if InputOptionsMenu.choosingKeybind: return
	CoolMenu.curSelected = id
	getMoused = true

func un_moused():
	if InputOptionsMenu.choosingKeybind: return
	CoolMenu.curSelected = -1
	getMoused = false

func triggerKeybindUpdate():
	keyingBinds.emit()
	$Idk/OptChoice.text = '... '
	set_process_unhandled_input(true)
	CoolMenu.play_sfx('Tick')

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventKey) || (event is InputEventJoypadButton) || (event is InputEventJoypadMotion):
		if event.is_pressed():
			InputMap.action_erase_events(optInternal)
			InputMap.action_add_event(optInternal, event)
			
			OptionsUtils.keyBince[optInternal] = event
			
			OptionsUtils.save_controls()
			
			selectCooldown = 3
			set_process_unhandled_input(false)
			updateMyStuff()
			CoolMenu.play_sfx('Go')
			noBinds.emit()

func updateMyStuff():
	$Idk/OptName.text = optName
	if OptionsUtils.get_prefs_info()['buttonType'] == 0: #if wii
		if GeneralUtils.replace_control_names(optInternal).begins_with('[img]'):
			$Idk/OptName.text += ' / ' + GeneralUtils.replace_control_names(optInternal)
	var coolEvents = InputMap.action_get_events(optInternal)
	if coolEvents.size() > 0:
		$Idk/OptChoice.text = ControllerIconUtils.get_event_bind_bbcode(coolEvents[0])
	$Idk/OptChoice.text += ' '
