extends Node
class_name MapUtils

static var map:JolasLevel

static func set_map(lv:JolasLevel):
	map = lv

static func spawn_object(name:String, pos:Vector2, variation:String = 'Default'):
# 1. Check if we are a client in a multiplayer game
	var m_api = Engine.get_main_loop().root.get_multiplayer()
	
	if m_api.multiplayer_peer is ENetMultiplayerPeer:
			MultiplayerMayhem._spawn_object.rpc(name, pos, variation)
			
	var object = load("res://Gamestuffs/Levelstuffs/Objects/" + name + "/" + variation + ".tscn").instantiate()
	map.add_child(object)
	object.position = pos
	return object

static func spawn_object_duplicate(name:String, pos:Vector2, variation:String = 'Default'):			
	var object = load("res://Gamestuffs/Levelstuffs/Objects/" + name + "/" + variation + ".tscn").instantiate()
	map.add_child(object)
	object.position = pos
	return object
