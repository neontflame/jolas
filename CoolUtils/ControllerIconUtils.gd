extends Node
class_name ControllerIconUtils

static var controllerIconPath = 'res://Gamestuffs/ControllerIcons/'

static var wiiMaps:Dictionary = {
	'ctrl_1': '1',
	'ctrl_2': '2',
	'ctrl_pause': 'Plus',
	'ctrl_interact': 'A'
}

static var ps3Maps:Dictionary = {
	'ctrl_1': 'Circle',
	'ctrl_2': 'X',
	'ctrl_pause': 'Start',
	'ctrl_interact': 'Triangle'
}

static var xbox360Maps:Dictionary = {
	'ctrl_1': 'B',
	'ctrl_2': 'A',
	'ctrl_pause': 'Start',
	'ctrl_interact': 'Y'
}

static var ps3Butts:Dictionary = {
	'buttons': {
		JOY_BUTTON_A: 'X',
		JOY_BUTTON_B: 'Circle',
		JOY_BUTTON_X: 'Square',
		JOY_BUTTON_Y: 'Triangle',
		JOY_BUTTON_BACK: 'Select',
		JOY_BUTTON_START: 'Start',
		JOY_BUTTON_LEFT_SHOULDER: 'L1',
		JOY_BUTTON_RIGHT_SHOULDER: 'R1'
	},
	'axis': {
		JOY_AXIS_TRIGGER_LEFT: 'L2',
		JOY_AXIS_TRIGGER_RIGHT: 'R2'
	}
}

static var xbox360Butts:Dictionary = {
	'buttons': {
		JOY_BUTTON_A: 'A',
		JOY_BUTTON_B: 'B',
		JOY_BUTTON_X: 'X',
		JOY_BUTTON_Y: 'Y',
		JOY_BUTTON_BACK: 'Back',
		JOY_BUTTON_START: 'Start',
		JOY_BUTTON_LEFT_SHOULDER: 'LButton',
		JOY_BUTTON_RIGHT_SHOULDER: 'RButton'
	},
	'axis': {
		JOY_AXIS_TRIGGER_LEFT: 'LTrigger',
		JOY_AXIS_TRIGGER_RIGHT: 'RTrigger'
	}
}

static var buttonNames:Dictionary = {
	'buttons': {
		JOY_BUTTON_A: 'A',
		JOY_BUTTON_B: 'B',
		JOY_BUTTON_X: 'X',
		JOY_BUTTON_Y: 'Y',
		JOY_BUTTON_BACK: 'Back',
		JOY_BUTTON_START: 'Start',
		JOY_BUTTON_LEFT_SHOULDER: 'L',
		JOY_BUTTON_RIGHT_SHOULDER: 'R',
		JOY_BUTTON_DPAD_UP: 'Cima',
		JOY_BUTTON_DPAD_DOWN: 'Baixo',
		JOY_BUTTON_DPAD_LEFT: 'Esquerda',
		JOY_BUTTON_DPAD_RIGHT: 'Direita',
	},
	'axis': {
		JOY_AXIS_TRIGGER_LEFT: 'L trigger',
		JOY_AXIS_TRIGGER_RIGHT: 'R trigger'
	}
}

# Input events
static func get_event_bind_bbcode(event:InputEvent):
	var coolReturns
	if OptionsUtils.get_prefs_info()['buttonType'] == 2:
		coolReturns = get_ps3_bind_bbcode(event)
	else:
		coolReturns = get_360_bind_bbcode(event)
	if coolReturns == null:
		coolReturns = get_button_name(event)
	if OptionsUtils.get_prefs_info()['buttonType'] == 3 || coolReturns == null:
		coolReturns = event.as_text()
	return coolReturns
	
static func get_ps3_bind_bbcode(event:InputEvent):
	var coolSauce = null
	if event is InputEventJoypadButton:
		if ps3Butts['buttons'].has(event.button_index):
			coolSauce = '[img]'
			coolSauce += controllerIconPath + 'PS3/' + ps3Butts['buttons'][event.button_index] + '.png'
			coolSauce += '[/img]'
	if event is InputEventJoypadMotion:
		print(event.axis)
		if ps3Butts['axis'].has(event.axis):
			coolSauce = '[img]'
			coolSauce += controllerIconPath + 'PS3/' + ps3Butts['axis'][event.axis] + '.png'
			coolSauce += '[/img]'
	return coolSauce

static func get_360_bind_bbcode(event:InputEvent):
	var coolSauce = null
	if event is InputEventJoypadButton:
		if xbox360Butts['buttons'].has(event.button_index):
			coolSauce = '[img]'
			coolSauce += controllerIconPath + 'X360/' + xbox360Butts['buttons'][event.button_index] + '.png'
			coolSauce += '[/img]'
	if event is InputEventJoypadMotion:
		if xbox360Butts['axis'].has(event.axis):
			coolSauce = '[img]'
			coolSauce += controllerIconPath + 'X360/' + xbox360Butts['axis'][event.axis] + '.png'
			coolSauce += '[/img]'
	return coolSauce

static func get_button_name(event:InputEvent):
	var coolSauce = null
	if event is InputEventJoypadButton:
		if buttonNames['buttons'].has(event.button_index):
			coolSauce = buttonNames['buttons'][event.button_index]
	if event is InputEventJoypadMotion:
		if buttonNames['axis'].has(event.axis):
			coolSauce += buttonNames['axis'][event.axis]
	return coolSauce

# Action icons
static func get_action_bind_bbcode(action:StringName):
	var coolReturns
	var actionEvent = InputMap.action_get_events(action)[0]
	if OptionsUtils.get_prefs_info()['buttonType'] == 0: # Wii
		coolReturns = get_wii_action_bbcode(action)
	if OptionsUtils.get_prefs_info()['buttonType'] == 1: # X360
		coolReturns = get_360_action_bbcode(action)
	if OptionsUtils.get_prefs_info()['buttonType'] == 2: # PS3
		coolReturns = get_ps3_action_bbcode(action)
	if coolReturns == null:
		coolReturns = get_button_name(actionEvent)
	if OptionsUtils.get_prefs_info()['buttonType'] == 3 || coolReturns == null:
		coolReturns = actionEvent.as_text()
	return coolReturns
	
static func get_wii_action_bbcode(action:StringName):
	var coolSauce = null
	if wiiMaps.has(action):
		coolSauce = '[img]'
		coolSauce += controllerIconPath + 'Wii/' + wiiMaps[action] + '.png'
		coolSauce += '[/img]'
	return coolSauce

static func get_360_action_bbcode(action:StringName):
	var coolSauce = null
	coolSauce = get_360_bind_bbcode(InputMap.action_get_events(action)[0])
	if coolSauce == null && xbox360Maps.has(action):
		coolSauce = '[img]'
		coolSauce += controllerIconPath + 'X360/' + xbox360Maps[action] + '.png'
		coolSauce += '[/img]'
	return coolSauce

static func get_ps3_action_bbcode(action:StringName):
	var coolSauce = null
	coolSauce = get_ps3_bind_bbcode(InputMap.action_get_events(action)[0])
	if coolSauce == null && ps3Maps.has(action):
		coolSauce = '[img]'
		coolSauce += controllerIconPath + 'PS3/' + ps3Maps[action] + '.png'
		coolSauce += '[/img]'
	return coolSauce
