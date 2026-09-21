extends Resource
class_name MapInfo

@export var name:String = "Mapa legal"

@export var regionString:String = ""
var region:RegionInfo

@export var extraSongfiles:Array[RegionSong] = []
@export var overrideSongs:bool = false

func _init() -> void:
	region = GameUtils.get_region_info(regionString)
	print(region.internalName)

func get_songfiles() -> Array[RegionSong]:
	var appendage:Array[RegionSong] = extraSongfiles
	if not overrideSongs:
		appendage.append_array(region.songfiles)
	return appendage
