extends Polygon2D

var sourcePolygon:PackedVector2Array
var moddedPolygon:PackedVector2Array

func _ready() -> void:
	sourcePolygon = polygon
	moddedPolygon = polygon

func _physics_process(delta: float) -> void:
	if not JolasGame.instance: return
	var cam:Camera2D = JolasGame.instance.playerInstance.coolCamera
	
	moddedPolygon[0].x = sourcePolygon[0].x + (cam.get_screen_center_position().x - 4200) * 0.75
	moddedPolygon[1].x = sourcePolygon[1].x + (cam.get_screen_center_position().x - 4200) * 0.75
	
	moddedPolygon[0].y = sourcePolygon[0].y + (cam.get_screen_center_position().y) * 0.75
	moddedPolygon[1].y = sourcePolygon[1].y + (cam.get_screen_center_position().y) * 0.75

	
	set_polygon(moddedPolygon)
