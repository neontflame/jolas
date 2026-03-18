extends Node2D
class_name PlaceDisplayerIngame

static var current_song: String = ""

@export var placeLabel:RichTextLabel
@export var songLabel:RichTextLabel
var canSong:bool = false
var coolTweenies:Array = []

func _ready() -> void:
	canSong = false
	placeLabel.visible = false
	songLabel.visible = false

func triggerPlaceInfo() -> void:
	placeLabel.text = "[img]res://Gamestuffs/HeadsUpDisplay/placeCoiso.png[/img] "
	placeLabel.text += GameUtils.get_map_info(GPStats.curMap)['name']
	
	if GameUtils.get_map_info(GPStats.curMap).has("song"):
		if GameUtils.get_map_info(GPStats.curMap)['song'] != PlaceDisplayerIngame.current_song:
			canSong = true
			PlaceDisplayerIngame.current_song = GameUtils.get_map_info(GPStats.curMap)['song']
			songLabel.text = "[img]res://Gamestuffs/HeadsUpDisplay/songCoiso.png[/img] "
			songLabel.text += GameUtils.get_map_info(GPStats.curMap)['song']
	
	doLabelTween(placeLabel)
	if canSong:
		await get_tree().create_timer(2).timeout
		doLabelTween(songLabel)

func doLabelTween(label):
	var tweeny: Tween
	label.visible_ratio = 0.0
	label.visible = true
	
	tweeny = create_tween()
	coolTweenies.append(tweeny)
	tweeny.tween_method(
		func(value): 
			label.visible_ratio = value
			# print(value)
			,  
		0.0, 1.0, 0.5)
	await tweeny.finished  
	coolTweenies.erase(tweeny)
	
	await get_tree().create_timer(1).timeout
	
	tweeny = create_tween()
	coolTweenies.append(tweeny)
	tweeny.tween_method(
		func(value): 
			label.visible_ratio = value
			# print(value)
			,  
		1.0, 0.0, 0.5)
	await tweeny.finished
	coolTweenies.erase(tweeny)
	label.visible = false
	
	tweeny.kill()
