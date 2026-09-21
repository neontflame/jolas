extends Resource
class_name MapInfo

@export var name:String = "Mapa legal"
@export var regionInfo:Dictionary[String, String] = {
	"name": "Região legal",
	"internalName": "RegiaoLegal"
}
@export var songfiles:Array[MapSong] = []
