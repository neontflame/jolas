extends MultiplayerSpawner

func _ready() -> void:
	for char in GameUtils.get_chars():
		add_spawnable_scene(GameUtils.get_char_asset_path(char, char + '.tscn'))
