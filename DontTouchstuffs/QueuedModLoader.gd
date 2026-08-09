extends Node2D

var loadArray:Array = []
var scriptsToRun:Array = []

var runScripts:Array = []

func _enter_tree() -> void:
	renderTexty()
	for mod in GameUtils.queuedMods:
		ProjectSettings.load_resource_pack(mod)
		GameUtils.loadedMods.append(mod)
		GameUtils.loadedModsFolderless.append(mod.get_file())
		loadArray.append(mod)
		if len(ModUtils.get_mod_info(mod)['runOnLoad']) > 0:
			for modscript in ModUtils.get_mod_info(mod)['runOnLoad']:
				scriptsToRun.append(modscript)
		renderTexty()
		await get_tree().create_timer(0.05).timeout
	
	await get_tree().create_timer(0.1).timeout
	
	GameUtils.queuedMods = []
	
	for script in scriptsToRun:
		var modscript = load(script).new()
		get_tree().root.add_child(modscript)
		runScripts.append(script)
		await get_tree().process_frame
		renderTextySkript()
		
	await get_tree().create_timer(0.1).timeout
	GeneralUtils.loadScene("res://Menustuffs/Menu.tscn")

func renderTexty():
	$Label.text = tr('mod_of_mods_loaded').format(
		{"loaded_mods": len(loadArray),
		"queued_mods": len(GameUtils.queuedMods)}
						)
	$Label2.text = ''
	for moddy in loadArray.slice(-24):
		$Label2.text += moddy + '\n'

func renderTextySkript():
	$Label.text = tr('script_of_scripts_run').format(
		{"loaded_scripts": len(runScripts),
		"queued_scripts": len(scriptsToRun)}
						)
	$Label2.text = ''
	for scripty in runScripts.slice(-24):
		$Label2.text += scripty + '\n'
