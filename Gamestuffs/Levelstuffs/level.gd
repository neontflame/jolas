extends Node2D
class_name JolasLevel

var player = GameUtils.get_char_asset(GPStats.char, GPStats.char + ".tscn")
var playerInstance
var dialogueInstance
var isDial := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playerInstance = player.instantiate()
	add_child(playerInstance)
	playerInstance.position = $Spawnpoint.position
	GPStats.setCharObject(playerInstance)
	MapUtils.set_map(self)
	SaveUtils.save_game(GPStats.saveNum)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	GPStats.process(_delta)
	
	if (Input.is_action_just_pressed("ui_accept")):
		playDialogue('diagTool')
	pass

func endDialogue() -> void:
	isDial = false
	playerInstance.movementEnabled = true
	playerInstance.process_mode = PROCESS_MODE_INHERIT
	dialogueInstance.disconnect('dialogue_end', endDialogue)
	remove_child(dialogueInstance)

func playDialogue(diagName:String):
	if !isDial:
		isDial = true
		playerInstance.movementEnabled = false
		playerInstance.process_mode = PROCESS_MODE_DISABLED
		if dialogueInstance: remove_child(dialogueInstance)
		dialogueInstance = load("res://Gamestuffs/Dialoguestuffs/DialogueScene.tscn").instantiate()
		add_child(dialogueInstance)
		dialogueInstance.parseDialogue(diagName)
		dialogueInstance.connect('dialogue_end', endDialogue)
