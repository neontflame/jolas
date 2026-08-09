extends Node2D
class_name DiagBase

#region Important Stuff
@export var blurBGFx:TextureRect

@export var diagControl:Control

@export var diagText:RichTextLabel
#endregion

#region Statements dreamed up by the utterly deranged
signal dialogue_end

var diagJson:Dictionary
var curDiagJson:Dictionary

var dialogueQuantity:int = 0
var dialogueLoaded:bool = false
var curDialogue:int = 1

var visibleChars := 0

var tween:Tween
var blurTween:Tween

var redirectDiag:String = ""

var isChoice:bool = false
var choices:Array = []
var curSelected:int = 0
#endregion

func _ready() -> void:
	curDialogue = 0
	dialogueLoaded = false
	# parseDialogue('diagTool')

func parseDialogue(diagFile:String):
	redirectDiag = ""
	var pathness:String = DiagUtils.get_dialogue_path(diagFile)
	diagJson = JSON.parse_string(FileUtils.get_text_file_content(pathness))
	dialogueQuantity = len(diagJson['dialogue'])
		
	if blurTween != null: blurTween.kill()
	blurTween = create_tween()
	blurTween.tween_method(
		func(value): blurBGFx.material.set_shader_parameter("amount", value),  
		0.0,  # Start value
		2.75,  # End value
		0.5     # Duration
	)
	dialogueLoaded = true
	await get_tree().create_timer(1/60).timeout
	runDiag(1)

func runDiag(diagNum: int):
	if diagNum > dialogueQuantity: return
	 
	if tween != null: tween.kill()
	visibleChars = 0
	var kIndex := 1
	for key in diagJson['dialogue'].keys():
		if kIndex == diagNum:
			curDiagJson = diagJson['dialogue'][key]
			break
		kIndex += 1
	curDialogue = diagNum
	
	diagText.bbcode_enabled = true
	
	opener(curDiagJson)
	
	if curDiagJson.has('line'):
		renderDiagLine()
	elif curDiagJson.has('choice'):
		renderDiagChoice()

#region Renderizaçao de texto ou algo do tipo
func renderDiagLine():
	# essa e a parte que o robo maldito fez
	isChoice = false
	diagText.text = GeneralUtils.text_replacery(curDiagJson['line'])
	diagText.visible_ratio = 0.0
	
	tween = create_tween()
	tween.tween_property(
							diagText, 
							"visible_ratio", 
							1.0, 
							diagText.get_parsed_text().length() * 0.03
							)
	# essa foi a parte que o robo maldito fez

func renderDiagChoice():
	isChoice = true
	# ideia:
	""" 
	"choice": {
		["Yeah!", "diagRedirect1"],
		["Nah.", "diagRedirect2"],
	}
	"""
	diagText.visible_ratio = 1.0
	visibleChars = diagText.visible_characters
	curSelected = 0
	
	choices = curDiagJson['choice']
	renderChoices()

func renderChoices():
	diagText.text = ''
	for ch in choices:
		diagText.text += ('> ' if choices[curSelected] == ch else '  ')
		diagText.text += GeneralUtils.text_replacery(ch[0])
		diagText.text += '\n'
#endregion


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
			skip_to_end()
			return 
		else:
			if curDialogue + 1 > dialogueQuantity:
				if redirectDiag and redirectDiag != "":
					parseDialogue(redirectDiag)
					return
				else:
					if diagJson.has('questClear') and diagJson['questClear'] != "":
						QuestUtils.conclude(diagJson['questClear'])
					if diagJson.has('questAssigned') and diagJson['questAssigned'] != "":
						QuestUtils.assign(diagJson['questAssigned'])
					set_visibles(false)
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
		
	if visibleChars < diagText.visible_characters:
		animate(curDiagJson)
		visibleChars = diagText.visible_characters

#region Scripting
func opener(diagjson:Dictionary):
	pass

func animate(diag):
	$Sounds/TickSound.play()

func set_visibles(visibility:bool):
	pass

func skip_to_end():
	pass
#endregion
