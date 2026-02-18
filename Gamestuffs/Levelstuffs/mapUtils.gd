extends Node
class_name MapUtils

static var map:JolasLevel

static func set_map(lv:JolasLevel):
	map = lv

static func spawn_object(name:String, pos:Vector2, variation:String = 'Default'):
	var object = load("res://Gamestuffs/Levelstuffs/Objects/" + name + "/" + variation + ".tscn").instantiate()
	map.add_child(object)
	object.position = pos
	return object
