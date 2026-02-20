extends Node2D

var saveId:int = 0
signal onClicked

func renderSave():
	var coolSaveness:Dictionary = SaveUtils.get_save_info(saveId)
	
	if coolSaveness["new"] == true:
		$FullSave.visible = false
		$EmptySave.visible = true
	else:
		$EmptySave.visible = false
		$FullSave.visible = true
		# time info
		# nao usei pq isso nao funcionou tao bem quanto eu esperava
		"""
		var timely = coolSaveness["last-playtime"] - coolSaveness["first-playtime"]
		var timelyButAwesome = Time.get_time_dict_from_unix_time(timely)
		var timeString = ''
		
		if timelyButAwesome["hour"] > 0:
			timeString += str(timelyButAwesome["hour"]) + 'h '
			
		if timelyButAwesome["minute"] > 0:
			timeString += str(timelyButAwesome["minute"]) + 'min'
		"""
		
		# player info
		$FullSave/Icon.texture = GameUtils.get_char_asset(coolSaveness["player"], "Icon.png")
		$FullSave/LvCount.text = 'Nível ' + str(GeneralUtils.display_number(coolSaveness["level"]))
		var mapInfo = GameUtils.get_map_info(coolSaveness["map"])
		$FullSave/CurMap.text = mapInfo["name"] + ' - ' + mapInfo["region"]
		# $FullSave/Timespan.text = timeString
		$FullSave/CurChar.text = GameUtils.get_char_info(coolSaveness["player"])["name"]
		
		if coolSaveness["applied-mods"] != []:
			$SaveBox.self_modulate.b = 0
	pass

func renderSaveOnline():
	var coolSaveness:Dictionary = SaveUtils.get_save_info(saveId)
	
	print(GPStats.char)
	$Icon.texture = GameUtils.get_char_asset(GPStats.char, "Icon.png")
	$CurChar.text = GameUtils.get_char_info(GPStats.char)["name"]
	
	if coolSaveness["new"] == true:
		$FullSave.visible = false
		$EmptySave.visible = true
	else:
		$EmptySave.visible = false
		$FullSave.visible = true
		# player info
		$FullSave/LvCount.text = 'Nível ' + str(GeneralUtils.display_number(coolSaveness["level"]))
		var mapInfo = GameUtils.get_map_info(coolSaveness["map"])
		$FullSave/CurMap.text = mapInfo["name"] + ' - ' + mapInfo["region"]
		# $FullSave/Timespan.text = timeString

		if GameUtils.loadedMods != []:
			$SaveBox.self_modulate.b = 0
			$ModWarning.visible = true
		else:
			$SaveBox.self_modulate.b = 1
			$ModWarning.visible = false
	pass

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if Input.is_action_just_pressed("ui_click"):
		onClicked.emit()
