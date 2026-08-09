extends DiagBase

@export var flippable:Node2D

@export var charName:Sprite2D
@export var portraitPos:Node2D

var portrite # zomg reference!
var customTalkies:DiagTalksound

var playCharSound:bool = false

#region Scripting
func opener(diagjson:Dictionary):
	if portrite != null: 
		portrite.queue_free()
	
	var character: String = diagjson['char'].capitalize()
	if DiagUtils.get_portrait_path(character):
		charName.visible = true
		charName.texture = DiagUtils.get_coolname(character)
		portrite = DiagUtils.get_portrait(character).instantiate()
		flippable.add_child(portrite)
		portrite.ptrt.play(diagjson['mood'])
		portrite.ptrt.set_frame(0)
	else:
		charName.visible = false
	
	var flip:bool = (diagjson['position'] == 'left')
	flippable.scale.x = (-1 if flip else 1)
	charName.flip_h = flip
	if portrite != null:
		portrite.position = portraitPos.position + Vector2(200, 0)
		portrite.intendedPos = portraitPos.position
	
	if DiagUtils.get_talksound_path(character):
		playCharSound = true
		customTalkies = DiagUtils.get_talksound(character)
		$Sounds/DiagSound.stream = customTalkies.talkStream
	else:
		playCharSound = false


func runDiag(diagNum:int):
	super.runDiag(diagNum)

func animate(diag):
	if portrite != null:
		if !portrite.ptrt.is_playing(): 
			portrite.ptrt.play(str(diag['mood']))
	if playCharSound:
		if not customTalkies.talksoundWaits \
		or (customTalkies.talksoundWaits and not $Sounds/DiagSound.playing):
			portrite.talksound.play()
	else:
		$Sounds/TickSound.play()

func set_visibles(visibility:bool):
	flippable.visible = visibility

func skip_to_end():
	if portrite != null: portrite.ptrt.set_frame(2)
#endregion
