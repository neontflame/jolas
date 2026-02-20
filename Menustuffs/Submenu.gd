extends Node2D
class_name Submenu

static var saveMenu
static var instance

func _enter_tree() -> void:
	Submenu.instance = self

func change_self_scene(coolscene:String):
	if Submenu.saveMenu: Submenu.saveMenu.queue_free()
	Submenu.saveMenu = load(coolscene).instantiate()
	get_parent().add_child(Submenu.saveMenu)
	Submenu.saveMenu.z_index = z_index
	call_deferred('queue_free')
