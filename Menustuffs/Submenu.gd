extends Node2D

func change_self_scene(coolscene:String):
	var saveMenu = load(coolscene).instantiate()
	get_parent().add_child(saveMenu)
	saveMenu.z_index = z_index
	queue_free()
