extends Node2D

func _process(delta: float) -> void:
	if !GPStats.charObject: return
	
	$ElecBar.set_size(
		Vector2(
			lerp($ElecBar.size.x, 
			float(144.0 / GPStats.charObject.ELEC_GAUGE_MAX) * GPStats.charObject.ELECTRICITY,
			0.5),
			$ElecBar.size.y
			)
	)
	$ElecBar.visible = GPStats.charObject.ELECTRICITY > 0.0
