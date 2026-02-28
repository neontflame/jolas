extends Node
class_name ControllerIconUtils

static var controllerIconPath = 'res://Gamestuffs/ControllerIcons/'

static var wiiMaps:Dictionary = {
	'ctrl_1': '1',
	'ctrl_2': '2',
	'ctrl_pause': 'Plus',
	'ctrl_interact': 'A',
	'ui_cancel': '1',
	'ui_accept': '2'
}

static var ps3Maps:Dictionary = {
	'ctrl_1': 'Circle',
	'ctrl_2': 'X',
	'ctrl_jump': 'Square',
	'ctrl_pause': 'Start',
	'ctrl_interact': 'Triangle',
	'ui_cancel': 'Circle',
	'ui_accept': 'X'
}

static var xbox360Maps:Dictionary = {
	'ctrl_1': 'B',
	'ctrl_2': 'A',
	'ctrl_jump': 'X',
	'ctrl_pause': 'Start',
	'ctrl_interact': 'Y',
	'ui_cancel': 'B',
	'ui_accept': 'A'
}

static var dreamcastMaps:Dictionary = {
	'ctrl_1': 'B',
	'ctrl_2': 'A',
	'ctrl_jump': 'X',
	'ctrl_pause': 'Start',
	'ctrl_interact': 'Y',
	'ui_cancel': 'B',
	'ui_accept': 'A'
}

static var gamecubeMaps:Dictionary = {
	'ctrl_1': 'B',
	'ctrl_2': 'A',
	'ctrl_jump': 'X',
	'ctrl_pause': 'Start',
	'ctrl_interact': 'Y',
	'ui_cancel': 'B',
	'ui_accept': 'A'
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

static var gamecubeButts:Dictionary = {
	# so um adendo
	# eu nao sei se isso vai funcionar 
	# eu nao tenho um adaptador de gamecube pra pc xP
	'buttons': {
		JOY_BUTTON_A: 'A',
		JOY_BUTTON_B: 'B',
		JOY_BUTTON_X: 'X',
		JOY_BUTTON_Y: 'Y',
		JOY_BUTTON_START: 'StartPause',
		JOY_BUTTON_RIGHT_SHOULDER: 'Z'
	},
	'axis': {
		JOY_AXIS_TRIGGER_LEFT: 'L',
		JOY_AXIS_TRIGGER_RIGHT: 'R'
	}
}

static var dreamcastButts:Dictionary = {
	# similarmente eu tambem nao sei se isso vai dar certo 
	# pq eu nao tenho um adaptador ou um controle!
	'buttons': {
		JOY_BUTTON_A: 'A',
		JOY_BUTTON_B: 'B',
		JOY_BUTTON_X: 'X',
		JOY_BUTTON_Y: 'Y',
		JOY_BUTTON_START: 'Start'
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
		JOY_AXIS_TRIGGER_RIGHT: 'R trigger',
		JOY_AXIS_LEFT_X: 'Analógico Esq. X',
		JOY_AXIS_LEFT_Y: 'Analógico Esq. Y',
		JOY_AXIS_RIGHT_X: 'Analógico Dir. X',
		JOY_AXIS_RIGHT_Y: 'Analógico Dir. Y'
	}
}

# Input events
static func get_event_bind_bbcode(event:InputEvent):
	var coolReturns
	if OptionsUtils.get_prefs_info()['buttonType'] == 2:
		coolReturns = get_generic_bind_bbcode(event, ps3Butts, 'PS3')
	elif OptionsUtils.get_prefs_info()['buttonType'] == 3:
		coolReturns = get_generic_bind_bbcode(event, gamecubeButts, 'GC')
	elif OptionsUtils.get_prefs_info()['buttonType'] == 4:
		coolReturns = get_generic_bind_bbcode(event, dreamcastButts, 'DC')
	else:
		coolReturns = get_generic_bind_bbcode(event, xbox360Butts, 'X360')
	if coolReturns == null:
		coolReturns = get_button_name(event)
	if OptionsUtils.get_prefs_info()['buttonType'] == 5 || coolReturns == null:
		coolReturns = event.as_text()
	return coolReturns

static func get_generic_bind_bbcode(event:InputEvent, butts:Dictionary, folder:String):
	var coolSauce = null
	if event is InputEventJoypadButton:
		if butts['buttons'].has(event.button_index):
			coolSauce = '[img]'
			coolSauce += controllerIconPath + folder + '/' + butts['buttons'][event.button_index] + '.png'
			coolSauce += '[/img]'
	if event is InputEventJoypadMotion:
		print(event.axis)
		if butts['axis'].has(event.axis):
			coolSauce = '[img]'
			coolSauce += controllerIconPath + folder + '/' + butts['axis'][event.axis] + '.png'
			coolSauce += '[/img]'
	return coolSauce

static func get_button_name(event:InputEvent):
	var coolSauce = null
	if event is InputEventJoypadButton:
		if buttonNames['buttons'].has(event.button_index):
			coolSauce = buttonNames['buttons'][event.button_index]
	if event is InputEventJoypadMotion:
		if buttonNames['axis'].has(event.axis):
			coolSauce = buttonNames['axis'][event.axis]
			coolSauce += ('+' if event.axis_value >= 0 else '-')
	return coolSauce

# Action icons
static func get_action_bind_bbcode(action:StringName):
	var coolReturns
	var actionEvent = InputMap.action_get_events(action)[0]
	if OptionsUtils.get_prefs_info()['buttonType'] == 0: # Wii
		coolReturns = get_wii_action_bbcode(action)
	if OptionsUtils.get_prefs_info()['buttonType'] == 1: # X360
		coolReturns = get_generic_action_bbcode(action, xbox360Butts, xbox360Maps, 'X360')
	if OptionsUtils.get_prefs_info()['buttonType'] == 2: # PS3
		coolReturns = get_generic_action_bbcode(action, ps3Butts, ps3Maps, 'PS3')
	if OptionsUtils.get_prefs_info()['buttonType'] == 3: # GameCube
		coolReturns = get_generic_action_bbcode(action, gamecubeButts, gamecubeMaps, 'GC')
	if OptionsUtils.get_prefs_info()['buttonType'] == 4: # Dreamcast
		coolReturns = get_generic_action_bbcode(action, dreamcastButts, dreamcastMaps, 'DC')
	if coolReturns == null:
		coolReturns = get_button_name(actionEvent)
	if OptionsUtils.get_prefs_info()['buttonType'] == 5 || coolReturns == null:
		coolReturns = actionEvent.as_text()
	return coolReturns
	
static func get_wii_action_bbcode(action:StringName):
	var coolSauce = null
	if wiiMaps.has(action):
		coolSauce = '[img]'
		coolSauce += controllerIconPath + 'Wii/' + wiiMaps[action] + '.png'
		coolSauce += '[/img]'
	return coolSauce

static func get_generic_action_bbcode(action:StringName, butts:Dictionary, maps:Dictionary, folder:String):
	var coolSauce = null
	coolSauce = get_generic_bind_bbcode(InputMap.action_get_events(action)[get_action_gp_index(action)], butts, folder)
	if coolSauce == null && maps.has(action):
		coolSauce = '[img]'
		coolSauce += controllerIconPath + folder + '/' + maps[action] + '.png'
		coolSauce += '[/img]'
	return coolSauce
	
# utilitario ok!
static func get_action_gp_index(action:StringName):
	var coolIndex = 0
	for eventy in InputMap.action_get_events(action):
		if eventy is InputEventJoypadButton or eventy is InputEventJoypadMotion:
			return coolIndex
		coolIndex += 1
	return 0 #placery
