extends JolasMap

func _enter_tree() -> void:
	GameUtils.get_map_info("especulamente.com.br")
	super._ready()
