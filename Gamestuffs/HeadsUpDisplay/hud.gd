extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/PlayerIcon.texture = GameUtils.get_char_asset(GPStats.char, "Icon.png")
	var customHUD = GameUtils.get_char_asset(GPStats.char, "HUD.tscn")
	if customHUD:
		$CanvasLayer.add_child(customHUD.instantiate())
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var hueShift = fmod((GPStats.level - 1) * 7.5, 100.0) / 100.0
	$CanvasLayer/LevelLabel.text = str(GPStats.level)
	$CanvasLayer/LevelSquare.material.set_shader_parameter('shift_hue', hueShift)
	
	if !GPStats.charObject: return
	
	$CanvasLayer/anchortest/TestLabel.text = 'vel x: ' + GeneralUtils.display_number(GPStats.charObject.motion.x) + ' | vel y: ' + GeneralUtils.display_number(GPStats.charObject.motion.y)


	$CanvasLayer/Bars/HPText.text = GeneralUtils.display_number(GPStats.charObject.hp) + "/" + str(GPStats.maxHP)
	$CanvasLayer/Bars/XPText.text = GeneralUtils.display_number(GPStats.xp) + "/" + str(GPStats.level * GPStats.lvLimit)
	
	# treco tinha quebrado aqui ai eu fui ver o que era
	# eu esqueci de colocar um .0 depois do 144
	$CanvasLayer/Bars/HPBar.set_size(
		Vector2(
			lerp($CanvasLayer/Bars/HPBar.size.x, 
			float(144.0 / GPStats.maxHP) * GPStats.charObject.hp,
			0.5),
			$CanvasLayer/Bars/HPBar.size.y
			)
	)
	$CanvasLayer/Bars/XPBar.set_size(
		Vector2(
			lerp($CanvasLayer/Bars/XPBar.size.x, 
			float(144.0 / (GPStats.level * GPStats.lvLimit)) * GPStats.xp,
			0.5),
			$CanvasLayer/Bars/XPBar.size.y
			)
	)

var connected := false
