extends JolasMap

func _ready() -> void:
	super._ready()
	$StaticBody2D/Polygon2D.polygon = $StaticBody2D/CollisionPolygon2D.polygon
