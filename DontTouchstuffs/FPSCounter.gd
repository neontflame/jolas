extends Node2D
@export var testLabel:Label

func _physics_process(delta: float) -> void:
	testLabel.visible = (OptionsUtils.get_prefs_info()['fpsCounter'] == 1)
	testLabel.text = 'FPS: ' + GeneralUtils.display_number(Engine.get_frames_per_second()) 
	if OS.is_debug_build():
		testLabel.text += ' | MEM: ' + FileUtils.format_bytes(OS.get_static_memory_usage())
