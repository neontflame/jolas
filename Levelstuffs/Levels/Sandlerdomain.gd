extends JolasMap
var isBossing:bool = false

func _ready() -> void:
	super._ready()
	$StaticBody2D/Polygon2D.polygon = $StaticBody2D/CollisionPolygon2D.polygon
	$StaticBody2D2/Polygon2D.polygon = $StaticBody2D2/CollisionPolygon2D.polygon

func _physics_process(_delta: float) -> void:
	$StaticBody2D2.visible = not $StaticBody2D2/CollisionPolygon2D.disabled
	$StaticBody2D2/CollisionPolygon2D.disabled = not (isBossing && allPlayersInBossRoom)

func removeEdgy():
	$EdgyCoiso.visible = false

func bossStart():
	await get_tree().process_frame
	isBossing = true

func bossEnd():
	isBossing = false
