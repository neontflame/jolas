extends Node2D

var saveId:int = 0

func renderSave():
	var coolSaveness:Dictionary = SaveUtils.get_save_info(saveId)
	
	if coolSaveness["new"] == true:
		$FullSave.visible = false
		$EmptySave.visible = true
	else:
		$EmptySave.visible = false
		$FullSave.visible = true
		# player info
		$FullSave/Icon.texture = GameUtils.get_char_icon(coolSaveness["player"])
		$FullSave/LvCount.text = 'Nível ' + str(GeneralUtils.display_number(coolSaveness["level"]))
		var mapInfo = GameUtils.get_map_info(coolSaveness["map"])
		$FullSave/CurMap.text = mapInfo["name"] + ' - ' + mapInfo["region"]
		$FullSave/CurChar.text = GameUtils.get_char_info(coolSaveness["player"])["name"]
	pass
