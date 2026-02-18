extends Node2D

func _process(delta: float) -> void:
	if !GPStats.charObject: return
	
	$AmmoBars.region_rect = Rect2(
		0, 
		0, 
		lerp(
		$AmmoBars.region_rect.size.x,
		GPStats.charObject.ammo * 12.0,
		0.2), 
		16
		)
