@tool
extends JolasMap
var isBossing:bool = false

@export var ss2dCool:SS2D_Shape

func _ready() -> void:
	var grad:GradientTexture1D = GradientTexture1D.new()
	grad.gradient = Gradient.new()
	grad.gradient.remove_point(1)
	grad.gradient.set_color(0, Color.FIREBRICK)
	
	ss2dCool.shape_material.set_fill_textures([grad])
	
	super()

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	#$StaticBody2D2.visible = not $StaticBody2D2/CollisionPolygon2D.disabled
	#$StaticBody2D2/CollisionPolygon2D.disabled = not (isBossing && allPlayersInBossRoom)

func removeEdgy():
	$EdgyCoiso.visible = false
