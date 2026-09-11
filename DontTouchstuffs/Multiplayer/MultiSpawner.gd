extends MultiplayerSpawner

func _ready() -> void:
	for char in GameUtils.get_chars():
		add_spawnable_scene(GameUtils.get_char_asset_path(char, char + '.tscn'))
		
		if GameUtils.get_char_info(char).has('addToMultiplayer'):
			var addArray:Array = GameUtils.get_char_info(char)['addToMultiplayer']
			for thing in addArray:
				add_spawnable_scene(thing)
