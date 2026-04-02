extends JolasLevel

func _enter_tree() -> void:
	$StaticBody2D/Polygon2D.position = $StaticBody2D/CollisionPolygon2D.position
	$StaticBody2D/Polygon2D.polygon = $StaticBody2D/CollisionPolygon2D.polygon
