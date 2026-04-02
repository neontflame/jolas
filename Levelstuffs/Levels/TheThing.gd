extends JolasLevel

func _ready() -> void:
	$StaticBody2D/Polygon2D.polygon = $StaticBody2D/CollisionPolygon2D.polygon
	$StaticBody2D2/Polygon2D.polygon = $StaticBody2D2/CollisionPolygon2D.polygon
