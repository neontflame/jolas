class_name GameInit
extends Node2D

static func setupGameInfo():
	GameUtils.isMobile = 	OS.has_feature("mobile") \
							or GameUtils.testingMobile
	
	#OptionsUtils.preferences.merge(await OptionsUtils.get_prefs_info(), true)
	await OptionsUtils.join_prefs_from_info()
	await OptionsUtils.get_controls_info()
	await UnlockUtils.merge_to_vars()
	await QuestUtils.clear_all()

func setupAutoloadMods():
	var enabledMods = FileUtils.get_text_file_content('%s/loadedMods.txt' % FileUtils.get_user_path())
	var modsSplit = enabledMods.split("\n")
	for mod in modsSplit:
		ModUtils.queuedMods.append(mod)

func _ready() -> void:
	await GameInit.setupGameInfo()
	await setupAutoloadMods()
	
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
				OnlineUtils.portEntered = int(initSplit[1])
		
		if len(ModUtils.queuedMods) > 0:
			for mod in ModUtils.queuedMods:
				print('Carregando mod: %s' % mod)
				ProjectSettings.load_resource_pack(ModUtils.get_mod_path(mod))
				ModUtils.loadedMods.append(mod)
			print('Total de mods carregados: %s' % len(ModUtils.queuedMods))
			ModUtils.queuedMods = []
		GeneralUtils.loadScene("res://Gamestuffs/Game.tscn")
	else:
		if len(ModUtils.queuedMods) > 0:
			get_tree().change_scene_to_file("res://DontTouchstuffs/QueuedModLoader.tscn")
		else:
			GeneralUtils.loadScene(ProjectSettings.get_setting("application/run/main_scene"))
