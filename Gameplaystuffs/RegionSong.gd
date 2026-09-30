extends Resource
class_name RegionSong

@export var name:String = "Placesong"
@export var songfile:AudioStream
@export var loops:bool = true

func get_filename():
	var pathle = songfile.resource_path
	return songfile.resource_path.get_file().remove_chars(".%s" % pathle.get_extension())
