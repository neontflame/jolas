extends Node2D

#region Actually Important
signal dialogue_end
@export var blurBGFx:TextureRect

@export var diagControl:Control

@export var charName:Sprite2D
@export var speechBubble:Sprite2D
@export var diagText:RichTextLabel
@export_category('Portrait Positions')
@export var port_LeftPos:Node2D
@export var port_RightPos:Node2D
#endregion

#region Weird shit
var theJayson:Dictionary
var dialogueQuantity:int = 0
var dialogueLoaded:bool = false
var curDialogue:int = 1
var intendedText:String = ''
var portrite # zomg reference!

var numTimer := 3
var tween:Tween
var blurTween:Tween

var isChoice:bool = false
var redirectDiag:String = ""
var choices:Array = []
var curSelected:int = 0
#endregion
	
func _ready() -> void:
	curDialogue = 0
	dialogueLoaded = false
	#parseDialogue('diagTool')

func parseDialogue(diagFile:String):
	redirectDiag = ""
	var pathness:String = FileUtils.get_localized_file('res://Gamestuffs/Dialoguestuffs/Dialogues/' + diagFile + '.json')
	theJayson = JSON.parse_string(FileUtils.get_text_file_content(pathness))
	if theJayson.has('questClear') and theJayson['questClear'] != "":
		QuestUtils.conclude(theJayson['questClear'])
	if theJayson.has('questAssigned') and theJayson['questAssigned'] != "":
		QuestUtils.assign(theJayson['questAssigned'])
	dialogueQuantity = len(theJayson['dialogue'])
		
	if blurTween != null: blurTween.kill()
	blurTween = create_tween()
	blurTween.tween_method(
		func(value): blurBGFx.material.set_shader_parameter("amount", value),  
		0.0,  # Start value
		2.75,  # End value
		0.5     # Duration
	)
	dialogueLoaded = true
	runDiag(1)

var CoolDial:Dictionary
var numberOfVisibles := 0

# eu inicialmente tava fazendo isso na mao so que o negocio ficava Travando
# entao eu tive que delegar a parte de mostrar o texto pro robo maldito
# 							(o efeito de typewriter no caso)
# mas o resto fui eu
func runDiag(diagNum: int):
	if diagNum > dialogueQuantity: return
	 
	if tween != null: tween.kill()
	numberOfVisibles = 0
	#CoolDial = theJayson['dialogue']["line" + str(diagNum)]
	var kIndex := 1
	for key in theJayson['dialogue'].keys():
		if kIndex == diagNum:
			CoolDial = theJayson['dialogue'][key]
			break
		kIndex += 1
	# print(CoolDial)
	curDialogue = diagNum
	
	if portrite != null: 
		# portrite.ptrt.stop()
		portrite.queue_free()
	
	var character: String = CoolDial['char'].capitalize()
	if (ResourceLoader.exists("res://Playerstuffs/Characters/" + character + "/Portrait.tscn")):
		charName.visible = true
		charName.texture = GameUtils.get_char_asset(character, "DiagName.png")
		portrite = GameUtils.get_char_asset(character, "Portrait.tscn").instantiate()
		diagControl.add_child(portrite)
		portrite.ptrt.play(CoolDial['mood'])
		portrite.ptrt.set_frame(0)
	else:
		charName.visible = false
	
	if CoolDial['position'] == 'right':
		charName.position = Vector2(690.0, 387.0) - Vector2(380.0, 230.0)
		speechBubble.flip_h = false
		if portrite != null:
			portrite.ptrt.flip_h = false
			portrite.position = port_RightPos.position + Vector2(200, 0)
			portrite.intendedPos = port_RightPos.position
	else:
		charName.position = Vector2(110.0, 387.0) - Vector2(380.0, 230.0)
		speechBubble.flip_h = true
		if portrite != null:
			portrite.ptrt.flip_h = true
			portrite.position = port_LeftPos.position + Vector2(-200, 0)
			portrite.intendedPos = port_LeftPos.position

	diagText.bbcode_enabled = true
	
	if CoolDial.has('line'):
		# essa e a parte que o robo maldito fez
		isChoice = false
		diagText.text = GeneralUtils.text_replacery(CoolDial['line'])
		diagText.visible_ratio = 0.0
		
		tween = create_tween()
		tween.tween_property(
								diagText, 
								"visible_ratio", 
								1.0, 
								diagText.get_parsed_text().length() * 0.03
								)
		# essa foi a parte que o robo maldito fez
	elif CoolDial.has('choice'):
		isChoice = true
		# ideia:
		""" 
		"choice": {
			["Yeah!", "diagRedirect1"],
			["Nah.", "diagRedirect2"],
		}
		"""
		diagText.visible_ratio = 1.0
		numberOfVisibles = diagText.visible_characters
		curSelected = 0
		
		if portrite != null: portrite.ptrt.set_frame(2)
		
		choices = CoolDial['choice']
		renderChoices()

func _process(delta: float) -> void:
	# $DialogueCanvas.transform.origin.x = GeneralUtils.get_res_difference().x
	
	if !dialogueLoaded: return
	# $DialogueCanvas.offset.y = (DisplayServer.window_get_size().y/2.0) - (get_viewport_rect().size.y/2.0)
	if isChoice:
		# isso pode nao ser muito bem otimizado mas whatever
		if (Input.is_action_just_pressed('ui_up')):
			curSelected = wrap(curSelected - 1, 0, len(choices))
			renderChoices()
			$Sounds/TickSound.play()
		if (Input.is_action_just_pressed('ui_down')):
			curSelected = wrap(curSelected + 1, 0, len(choices))
			renderChoices()
			$Sounds/TickSound.play()
		if (Input.is_action_just_pressed('ui_accept') || Input.is_action_just_pressed('ctrl_interact')):
			redirectDiag = choices[curSelected][1]
			$Sounds/GoSound.play()
	
	if (Input.is_action_just_pressed('ui_accept') || Input.is_action_just_pressed('ctrl_interact')):
		if diagText.visible_ratio != 1.0:
			tween.kill()
			diagText.visible_ratio = 1.0
			if portrite != null: portrite.ptrt.set_frame(2)
			return 
		else:
			if curDialogue + 1 > dialogueQuantity:
				if redirectDiag and redirectDiag != "":
					parseDialogue(redirectDiag)
					return
				else:
					if portrite: portrite.visible = false
					speechBubble.visible = false
					charName.visible = false
					diagText.visible = false
					
					blurTween = create_tween()
					blurTween.tween_method(
						func(value): 
							blurBGFx.material.set_shader_parameter("amount", value)
							if value <= 0:
								print('endest')
								dialogue_end.emit()
							,  
						2.75,  # Start value
						0.0,  # End value
						0.5     # Duration
					)
					return
			runDiag(curDialogue + 1)
		
	if numberOfVisibles < diagText.visible_characters:
		coolAnimatione(CoolDial)
		numberOfVisibles = diagText.visible_characters
		
func coolAnimatione(coolDial):
	$Sounds/TickSound.play()
	if portrite != null && !portrite.ptrt.is_playing(): 
		portrite.ptrt.play(str(coolDial['mood']))

func renderChoices():
	diagText.text = ''
	for ch in choices:
		diagText.text += ('> ' if choices[curSelected] == ch else '  ')
		diagText.text += GeneralUtils.text_replacery(ch[0])
		diagText.text += '\n'
