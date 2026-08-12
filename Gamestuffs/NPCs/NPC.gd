extends Node2D
class_name NPC

var talkedTo:bool = false
var canTalk:bool = false
@export var dialogue:String = ''
# @export var dialogoPorChar:bool = false
@export var questCleared:String = ''

func _ready() -> void:
	$InteractText.text = ControllerIconUtils.get_action_bind_bbcode('ctrl_interact')
	$InteractText.visible = false

func _body_entered(body: Node2D) -> void:
	$InteractText.text = ControllerIconUtils.get_action_bind_bbcode('ctrl_interact')
	if body is PlayerObject:
		canTalk = true
		interaction(true)

func _body_exited(body: Node2D) -> void:
	if body is PlayerObject:
		canTalk = false
		interaction(false)

func _physics_process(delta: float) -> void:
	$InteractText.visible = canTalk
	
	if canTalk:
		if Input.is_action_just_pressed("ctrl_interact"):
			playDialogue()
			talkedTo = true

func playDialogue():
	JolasGame.instance.playDialogue(dialogue)

#region Scripcios
func interaction(able:bool):
	pass
#endregion
