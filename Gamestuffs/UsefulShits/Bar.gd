extends Node2D
class_name Bar

var progress:float = 1.0

func _physics_process(_delta: float) -> void:
	$FilledBar.visible = (progress > 0)
	if progress > 0:
		$FilledBar.set_size(
			Vector2(
				lerp($FilledBar.size.x, 
				($EmptyBar.texture.get_width() * progress),
				0.5),
				$FilledBar.size.y
				)
		)
