@tool
extends JolasMap

@export var ss2dCool:SS2D_Shape

func _ready() -> void:
	var grad:GradientTexture1D = GradientTexture1D.new()
	grad.gradient = Gradient.new()
	grad.gradient.remove_point(1)
	grad.gradient.set_color(0, Color.LIME_GREEN)
	
	ss2dCool.shape_material.set_fill_textures([grad])
	
	super()
