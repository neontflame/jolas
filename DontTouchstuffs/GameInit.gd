extends Node2D

func _ready() -> void:
	for argument in OS.get_cmdline_args():
		var arguString:String = str(argument)
		if arguString.begins_with("--mods="):
			var initSplit = arguString.split("=")
			var modsSplit = initSplit[1].split(",")
			for mod in modsSplit:
				GameUtils.queuedMods.append("user://" + mod)
	
	if DisplayServer.get_name() == "headless" \
	or "--server" in OS.get_cmdline_user_args():
		
		print('jolas.: Dedicações Abound - versão %s' % GameUtils.gameVersion)
		GPStats.is_dedicated_server = true
		GPStats.is_multiplayer = true
		GPStats.is_hosting = true
		
		for argument in OS.get_cmdline_args():
			var arguString:String = str(argument)
			if arguString.begins_with("--port="):
				var initSplit = arguString.split("=")
				GameUtils.portEntered = int(initSplit[1])
		
		if len(GameUtils.queuedMods) > 0:
			for mod in GameUtils.queuedMods:
				print('Carregando mod: %s' % mod)
				ProjectSettings.load_resource_pack(mod)
				GameUtils.loadedMods.append(mod)
				GameUtils.loadedModsFolderless.append(mod.get_file())
			print('Total de mods carregados: %s' % len(GameUtils.queuedMods))
			GameUtils.queuedMods = []
		get_tree().change_scene_to_file("res://Gamestuffs/Game.tscn")
	else:
		if len(GameUtils.queuedMods) > 0:
			get_tree().change_scene_to_file("res://DontTouchstuffs/QueuedModLoader.tscn")
		else:
			get_tree().change_scene_to_file("res://Menustuffs/Menu.tscn")
