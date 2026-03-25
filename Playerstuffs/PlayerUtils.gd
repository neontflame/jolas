extends Node
class_name PlayerUtils

static var myCamZoom:float = 1

static func is_jump_just_pressed():
	var canTapJump = (Input.is_action_just_pressed("ctrl_up") && OptionsUtils.get_prefs_info()['tapJump'] == 1) && !GPStats.charObject.up_override
	return (Input.is_action_just_pressed("ctrl_jump") || canTapJump)

static func is_jump_pressed():
	var canTapJump = (Input.is_action_pressed("ctrl_up") && OptionsUtils.get_prefs_info()['tapJump'] == 1) && !GPStats.charObject.up_override
	return (Input.is_action_pressed("ctrl_jump") || canTapJump)

static func is_jump_released():
	var canTapJump = (Input.is_action_just_released("ctrl_up") && OptionsUtils.get_prefs_info()['tapJump'] == 1) && !GPStats.charObject.up_override
	return (Input.is_action_just_released("ctrl_jump") || canTapJump)

static func set_default_zoom():
	myCamZoom = OptionsUtils.get_prefs_info()['genZoom'] + 0.5

static func get_camera_zoom(mult:float):
	return clamp(myCamZoom * mult, 0.5, 1.5)
