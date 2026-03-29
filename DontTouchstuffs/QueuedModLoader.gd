extends Node2D

var loadArray:Array = []

func _enter_tree() -> void:
	renderTexty()
	for mod in GameUtils.queuedMods:
		ProjectSettings.load_resource_pack(mod)
		GameUtils.loadedMods.append(mod)
		GameUtils.loadedModsFolderless.append(mod.get_file())
		loadArray.append(mod)
		renderTexty()
		await get_tree().create_timer(0.05).timeout
	GameUtils.queuedMods = []
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://Menustuffs/Menu.tscn")

func renderTexty():
	$Label.text = '%s de %s mods carregados\n' % [len(loadArray), len(GameUtils.queuedMods)]
	$Label2.text = ''
	for moddy in loadArray.slice(-24):
		$Label2.text += moddy + '\n'
