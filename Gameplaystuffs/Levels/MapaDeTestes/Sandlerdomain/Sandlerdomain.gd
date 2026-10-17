@tool
extends JolasMap
var isBossing:bool = false

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	#$StaticBody2D2.visible = not $StaticBody2D2/CollisionPolygon2D.disabled
	#$StaticBody2D2/CollisionPolygon2D.disabled = not (isBossing && allPlayersInBossRoom)

func removeEdgy():
	$EdgyCoiso.visible = false
