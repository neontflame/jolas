extends Node
class_name GeneralUtils

static func display_number(value: float) -> String:
	# Check if the value is approximately equal to its integer cast
	if is_equal_approx(value, int(value)):
		# If it is a whole number, format as an integer
		return str(int(value))
	else:
		# Otherwise, format as a float with a specific number of decimals (e.g., 2)
		return "%.2f" % value

static func get_res_difference() -> Vector2:
	return Vector2(
		(DisplayServer.window_get_size().x/2.0) - (ProjectSettings.get_setting("display/window/size/viewport_width")/2.0),
		(DisplayServer.window_get_size().y/2.0) - (ProjectSettings.get_setting("display/window/size/viewport_height")/2.0)
		)
		
static func get_default_screen_res() -> Vector2:
	return Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
		)

static func check_array_compat(array1:Array, array2:Array):
	if array1 == array2:
		return true
		
	for thingOne in array1:
		if !array2.has(thingOne):
			return false
	
	for thingTwo in array2:
		if !array1.has(thingTwo):
			return false
	
	# tem q ver dos dois lados neh
	return true

static func text_replacery(string:String):
	# isso e pra ser usado com BBCODE !!!!! RAAHH
	var stringReplacies:Array = [
		["ctrl_up", "Up"],
		["ctrl_down", "Down"],
		["ctrl_left", "Left"],
		["ctrl_right", "Right"],
		["ctrl_1", "CtrlOne"],
		["ctrl_2", "CtrlTwo"],
		["ctrl_jump", "Jump"],
		["ctrl_pause", "Pause"],
		["ctrl_interact", "Interact"]
	]
	
	var coolString:String = string
	for replacery in stringReplacies:
		replacery[1] = ControllerIconUtils.get_action_bind_bbcode(replacery[0])
		coolString = coolString.replace(replacery[0], replacery[1])
	
	return coolString

static func get_volume(type:String):
	OptionsUtils.get_prefs_info()
	
	match (type):
		'bgm':
			return OptionsUtils.preferences['volMaster'] * OptionsUtils.preferences['volBGM']
		'sfx':
			return OptionsUtils.preferences['volMaster'] * OptionsUtils.preferences['volSFX']
		_:
			return OptionsUtils.preferences['volMaster']

static func get_volume_db(type:String, mod:float = 0.0):
	return mod + linear_to_db(get_volume(type) + 0.001) 
