extends Node2D
var talkedTo:bool = false
var canTalk:bool = false
@export var dialogue:String = ''
@export var dialogoPorChar:bool = false

func _ready() -> void:
	$InteractText.text = ControllerIconUtils.get_action_bind_bbcode('ctrl_interact')
	$InteractText.visible = false

func _body_entered(body: Node2D) -> void:
	if body is PlayerObject:
		canTalk = true

func _body_exited(body: Node2D) -> void:
	if body is PlayerObject:
		canTalk = false

func _physics_process(delta: float) -> void:
	$InteractText.visible = canTalk
	
	if canTalk:
		if Input.is_action_just_pressed("ctrl_interact"):
			var extraCoiso:String = (' ' + GPStats.char if dialogoPorChar else '')
			JolasGame.instance.playDialogue(dialogue + extraCoiso)
			talkedTo = true
