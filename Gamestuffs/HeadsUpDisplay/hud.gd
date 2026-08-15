extends Node2D
class_name HeadsUpDisplay

@export_category('Hud shit')
@export var canvasLayer:CanvasLayer
@export var playerIcon:Sprite2D
@export var levelLabel:Label
@export var levelSquare:Sprite2D
@export var hpText:Label
@export var xpText:Label
@export var hpBar:NinePatchRect
@export var xpBar:NinePatchRect

@export var comboText:RichTextLabel
var combo_tween: Tween

@export var questIcon:Node2D
@export var inventoryIcon:Node2D
@export var placeInfo:PlaceDisplayerIngame

@export var notifsNode:Node2D

@export var sfxPlayer:AudioStreamPlayer

@export_category('Online hud shit')
@export var onlineElements:Control
var isWriting:bool = false
var textWait:Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	onlineElements.visible = GPStats.is_multiplayer
	playerIcon.texture = GameUtils.get_char_asset(GPStats.char, "Icon.png")
	var customHUD = GameUtils.get_char_asset(GPStats.char, "HUD.tscn")
	if customHUD:
		canvasLayer.add_child(customHUD.instantiate())
	
	if GameUtils.isMobile:
		var mobHUD = load("res://Gamestuffs/HeadsUpDisplay/mobileHud.tscn")
		canvasLayer.add_child(mobHUD.instantiate())
		comboText.position.x -= 51.0
	
	comboText.position.y = -64.0
	
	while GPStats.charObject == null:
		await get_tree().process_frame
	if GPStats.charObject:
		print("[HUD] sinais prontos")
		GPStats.charObject.comboIncrease.connect(show_combo_hud)
		GPStats.charObject.comboReset.connect(hide_combo_hud)
	else:
		print("[HUD] sinais nao conectados")
	
	JolasGame.instance.hud = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var hueShift = fmod((GPStats.level - 1) * 7.5, 100.0) / 100.0
	levelLabel.text = str(GPStats.level)
	levelSquare.material.set_shader_parameter('shift_hue', hueShift)
	
	if !GPStats.charObject: return
	# testLabel.text = 'vel x: ' + GeneralUtils.display_number(GPStats.charObject.motion.x) + ' | vel y: ' + GeneralUtils.display_number(GPStats.charObject.motion.y)
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
	
	if GPStats.is_multiplayer:
		if not isWriting:
			if Input.is_key_label_pressed(KEY_T):
				onlineElements.get_node('MsgTxt').grab_focus()
				isWriting = true
		isWriting = onlineElements.get_node('MsgTxt').has_focus()
		onlineElements.get_node('MsgTxt').visible = isWriting
		if isWriting:
			if Input.is_key_label_pressed(KEY_ENTER):
				var messageFormat:String = "<%s> %s" % [GameUtils.username, onlineElements.get_node('MsgTxt').text]
				MultiplayerMayhem._player_send_msg.rpc(GPStats.charObject.get_multiplayer_authority(), messageFormat)
				onlineElements.get_node('MsgTxt').text = ''
				onlineElements.get_node('MsgTxt').release_focus()
	
func show_combo_hud():
	comboText.text = "[img]res://Gamestuffs/HeadsUpDisplay/hud_ComboLabel.png[/img]" + GeneralUtils.display_number(GPStats.charObject.combo)
	var initial_pos: float
	if GPStats.charObject.combo == 1:
		initial_pos = -64.0
	else:
		initial_pos = 15.0
	
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

func play_sfx(name:String, volumeDB:float = 0.0):
	if sfxPlayer.playing: sfxPlayer.stop()
	sfxPlayer.stream = load("res://Gamestuffs/Sounds/Notifs/" + name + ".wav")
	sfxPlayer.volume_db = volumeDB
	sfxPlayer.play()

func add_to_msg_log(coolText:String):
	if textWait:
		textWait.queue_free()
	var logshit:RichTextLabel = onlineElements.get_node('MsgLogTxt')
	logshit.visible = true
	logshit.text += str(coolText)
	play_sfx('MSNMessage')
	textWait = Timer.new()
	add_child(textWait)
	textWait.start(5.0)
	await textWait.timeout
	logshit.visible = false

var notif_cooldown := 0.5  # seconds between notifs
var last_notif_time := -INF

func create_notif(msg:String, icon:String, sound:String):
	var now = Time.get_ticks_msec() / 1000.0
	var wait_time = (last_notif_time + notif_cooldown) - now
	if wait_time > 0:
		last_notif_time += notif_cooldown
		await get_tree().create_timer(wait_time).timeout
	else:
		last_notif_time = now

	for child in notifsNode.get_children():
		if child is Node2D:
			child.position.y += 32
	var newNotif = load("res://Gamestuffs/HeadsUpDisplay/Notif.tscn").instantiate()
	notifsNode.add_child(newNotif)
	newNotif.setup(msg, icon, sound)
