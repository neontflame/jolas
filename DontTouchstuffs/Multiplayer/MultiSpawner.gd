extends MultiplayerSpawner

func _ready() -> void:
	for char in GameUtils.get_chars():
		add_spawnable_scene(GameUtils.get_char_asset_path(char, char + '.tscn'))
		
		if len(GameUtils.get_char_info(char).addToMultiplayer) > 0:
			for thing in GameUtils.get_char_info(char).addToMultiplayer:
				add_spawnable_scene(thing)
