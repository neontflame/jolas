extends Node
class_name MapUtils

static var map:JolasLevel

static func set_map(lv:JolasLevel):
	map = lv

static func spawn_object(name:String, pos:Vector2, variation:String = 'Default', additionalData:Dictionary = {}):
# sabe a gente ate poderia fazer o additionalData ser na verdade um Callable
# mas o multiplayer embutido na godot e meio cu ent isso e impossivel
	var m_api = Engine.get_main_loop().root.get_multiplayer()
	
	if m_api.multiplayer_peer is ENetMultiplayerPeer:
			MultiplayerMayhem._spawn_object.rpc(name, pos, variation, additionalData)
			
	var object = load("res://Gamestuffs/Levelstuffs/Objects/" + name + "/" + variation + ".tscn").instantiate()
	map.add_child(object)
	object.position = pos
	if object.has_method("apply_additional_data") && additionalData != {}:
		object.apply_additional_data(additionalData)
	return object

static func spawn_object_online(name:String, pos:Vector2, variation:String = 'Default', additionalData:Dictionary = {}):			
	var object = load("res://Gamestuffs/Levelstuffs/Objects/" + name + "/" + variation + ".tscn").instantiate()
	map.add_child(object)
	object.position = pos
	if object.has_method("apply_additional_data") && additionalData != {}:
		object.apply_additional_data(additionalData)
	return object
