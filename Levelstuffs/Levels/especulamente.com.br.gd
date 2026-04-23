extends JolasMap

func _enter_tree() -> void:
	super._ready()
	GameUtils.get_map_info("especulamente.com.br")
