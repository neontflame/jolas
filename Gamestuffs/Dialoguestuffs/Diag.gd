extends Node2D

#region Actually Important
signal dialogue_end
#endregion

#region Weird shit
var theJayson
var dialogueQuantity:int = 0
var dialogueLoaded:bool = false
var curDialogue:int = 1
var intendedText:String = ''
var portrite # zomg reference!

var numTimer := 3
var tween:Tween
var blurTween:Tween
#endregion
	
func _ready() -> void:
	curDialogue = 0
	dialogueLoaded = false
	#parseDialogue('diagTool')

func parseDialogue(diagFile:String):
	var pathness := 'res://Gamestuffs/Dialoguestuffs/Dialogues/' + diagFile + '.json'
	theJayson = JSON.parse_string(FileUtils.get_text_file_content(pathness))
	dialogueQuantity = len(theJayson['dialogue'])
		
	if blurTween != null: blurTween.kill()
	blurTween = create_tween()
	blurTween.tween_method(
		func(value): $DialogueCanvas/BlurFx.material.set_shader_parameter("amount", value),  
		0.0,  # Start value
		2.75,  # End value
		0.5     # Duration
	)
	dialogueLoaded = true
	runDiag(1)

var CoolDial
var numberOfVisibles := 0

# eu inicialmente tava fazendo isso na mao so que o negocio ficava Travando
# entao eu tive que delegar a parte de mostrar o texto pro robo maldito
# 							(o efeito de typewriter no caso)
# mas o resto fui eu
func runDiag(diagNum: int):
	if diagNum > dialogueQuantity: return
	 
	if tween != null: tween.kill()
	numberOfVisibles = 0
	CoolDial = theJayson['dialogue']['line' + str(diagNum)]
	print(CoolDial)
	curDialogue = diagNum
	
	if portrite != null: 
		portrite.ptrt.stop()
		portrite.queue_free()
	
	var character: String = CoolDial['char'].capitalize()
	if (load("res://Playerstuffs/Characters/" + character + "/Portrait.tscn") != null):
		$DialogueCanvas/Control/CharName.visible = true
		$DialogueCanvas/Control/CharName.play(character)
		portrite = load("res://Playerstuffs/Characters/" + character + "/Portrait.tscn").instantiate()
		$DialogueCanvas/Control.add_child(portrite)
		portrite.ptrt.play(CoolDial['mood'])
		portrite.ptrt.set_frame(0)
	else:
		$DialogueCanvas/Control/CharName.visible = false
	
	if CoolDial['position'] == 'right':
		$DialogueCanvas/Control/CharName.position = Vector2(690.0, 387.0) - Vector2(380.0, 230.0)
		$DialogueCanvas/Control/BalaoDeFala.flip_h = false
		if portrite != null:
			portrite.ptrt.flip_h = false
			portrite.position = $DialogueCanvas/Control/PortraitRightPos.position + Vector2(200, 0)
			portrite.intendedPos = $DialogueCanvas/Control/PortraitRightPos.position
	else:
		$DialogueCanvas/Control/CharName.position = Vector2(110.0, 387.0) - Vector2(380.0, 230.0)
		$DialogueCanvas/Control/BalaoDeFala.flip_h = true
		if portrite != null:
			portrite.ptrt.flip_h = true
			portrite.position = $DialogueCanvas/Control/PortraitLeftPos.position + Vector2(-200, 0)
			portrite.intendedPos = $DialogueCanvas/Control/PortraitLeftPos.position

	# essa e a parte que o robo maldito fez
	$DialogueCanvas/Control/RichTextLabel.bbcode_enabled = true
	$DialogueCanvas/Control/RichTextLabel.text = CoolDial['line']
	$DialogueCanvas/Control/RichTextLabel.visible_ratio = 0.0
	
	tween = create_tween()
	tween.tween_property(
							$DialogueCanvas/Control/RichTextLabel, 
							"visible_ratio", 
							1.0, 
							$DialogueCanvas/Control/RichTextLabel.get_parsed_text().length() * 0.03
							)
	# essa foi a parte que o robo maldito fez

func _process(delta: float) -> void:
	# $DialogueCanvas.transform.origin.x = GeneralUtils.get_res_difference().x
	
	if !dialogueLoaded: return
	# $DialogueCanvas.offset.y = (DisplayServer.window_get_size().y/2.0) - (get_viewport_rect().size.y/2.0)
	
	if (Input.is_action_just_pressed('ui_accept')):
		if $DialogueCanvas/Control/RichTextLabel.visible_ratio != 1.0:
			tween.kill()
			$DialogueCanvas/Control/RichTextLabel.visible_ratio = 1.0
			if portrite != null: portrite.ptrt.set_frame(2)
			return 
		else:
			if curDialogue + 1 > dialogueQuantity:
				portrite.visible = false
				$DialogueCanvas/Control/BalaoDeFala.visible = false
				$DialogueCanvas/Control/CharName.visible = false
				$DialogueCanvas/Control/RichTextLabel.visible = false
				
				blurTween = create_tween()
				blurTween.tween_method(
					func(value): 
						$DialogueCanvas/BlurFx.material.set_shader_parameter("amount", value)
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
		
	if numberOfVisibles < $DialogueCanvas/Control/RichTextLabel.visible_characters:
		coolAnimatione(CoolDial)
		numberOfVisibles = $DialogueCanvas/Control/RichTextLabel.visible_characters
		
func coolAnimatione(coolDial):
	$Sounds/TickSound.play()
	if portrite != null && !portrite.ptrt.is_playing(): 
		portrite.ptrt.play(str(coolDial['mood']))
