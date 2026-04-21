extends Node2D
class_name HeadsUpDisplay

@export var canvasLayer:CanvasLayer
@export var playerIcon:Sprite2D
@export var levelLabel:Label
@export var levelSquare:Sprite2D
@export var hpText:Label
@export var xpText:Label
@export var hpBar:NinePatchRect
@export var xpBar:NinePatchRect
@export var testLabel:Label

@export var comboText:RichTextLabel
var combo_tween: Tween

@export var questIcon:Node2D
@export var placeInfo:PlaceDisplayerIngame

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playerIcon.texture = GameUtils.get_char_asset(GPStats.char, "Icon.png")
	var customHUD = GameUtils.get_char_asset(GPStats.char, "HUD.tscn")
	if customHUD:
		canvasLayer.add_child(customHUD.instantiate())
	comboText.position.y = -64.0
	
	while GPStats.charObject == null:
		await get_tree().process_frame
	if GPStats.charObject:
		print("sinais prontos")
		GPStats.charObject.comboIncrease.connect(show_combo_hud)
		GPStats.charObject.comboReset.connect(hide_combo_hud)
	else:
		print("sinais nao conectados")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var hueShift = fmod((GPStats.level - 1) * 7.5, 100.0) / 100.0
	levelLabel.text = str(GPStats.level)
	levelSquare.material.set_shader_parameter('shift_hue', hueShift)
	
	if !GPStats.charObject: return
	# testLabel.text = 'vel x: ' + GeneralUtils.display_number(GPStats.charObject.motion.x) + ' | vel y: ' + GeneralUtils.display_number(GPStats.charObject.motion.y)
	testLabel.text = 'FPS: ' + GeneralUtils.display_number(Engine.get_frames_per_second()) 
	if OS.is_debug_build():
		testLabel.text += ' | Memória: ' + FileUtils.format_bytes(OS.get_static_memory_usage())
	hpText.text = GeneralUtils.display_number(GPStats.charObject.hp) + "/" + str(GPStats.maxHP)
	xpText.text = GeneralUtils.display_number(GPStats.xp) + "/" + str(GPStats.level * GPStats.lvLimit)
	
	# treco tinha quebrado aqui ai eu fui ver o que era
	# eu esqueci de colocar um .0 depois do 144
	hpBar.set_size(
		Vector2(
			lerp(hpBar.size.x, 
			float(144.0 / GPStats.maxHP) * GPStats.charObject.hp,
			0.5),
			hpBar.size.y
			)
	)
	xpBar.set_size(
		Vector2(
			lerp(xpBar.size.x, 
			float(144.0 / (GPStats.level * GPStats.lvLimit)) * GPStats.xp,
			0.5),
			xpBar.size.y
			)
	)
	
	
func show_combo_hud():
	comboText.text = "[img]res://Gamestuffs/HeadsUpDisplay/hud_ComboLabel.png[/img]" + GeneralUtils.display_number(GPStats.charObject.combo)
	var initial_pos: float
	if GPStats.charObject.combo == 1:
		initial_pos = -64.0
	else:
		initial_pos = 20.0
	
	comboText.position.y = initial_pos
	if combo_tween and combo_tween.is_valid(): combo_tween.kill()
	combo_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	combo_tween.tween_property(comboText, "position:y", 10.0, 0.5)

func hide_combo_hud():
	if combo_tween and combo_tween.is_valid(): combo_tween.kill()
	combo_tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	combo_tween.tween_property(comboText, "position:y", -64.0, 0.5)
	await combo_tween.finished
	comboText.text = "[img]res://Gamestuffs/HeadsUpDisplay/hud_ComboLabel.png[/img]" + GeneralUtils.display_number(GPStats.charObject.combo)
