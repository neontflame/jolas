extends Node2D
class_name PlaceDisplayerIngame

static var current_song: String = ""

@export var placeLabel:RichTextLabel
@export var songLabel:RichTextLabel
var canPlace:bool = true
var canSong:bool = false
var coolTweenies:Array = []

func _ready() -> void:
	canSong = false
	placeLabel.visible = false
	songLabel.visible = false

func triggerPlaceInfo(songPlayed:RegionSong) -> void:
	var mapInfo = GameUtils.get_map_info(GPStats.curMap, GPStats.curRegion)
	
	placeLabel.text = "[img]res://Gamestuffs/HeadsUpDisplay/placeCoiso.png[/img] %s" % mapInfo.name
	
	if songPlayed != null:
		if songPlayed.name != PlaceDisplayerIngame.current_song:
			canSong = true
			PlaceDisplayerIngame.current_song = songPlayed.name
			songLabel.text = "[img]res://Gamestuffs/HeadsUpDisplay/songCoiso.png[/img] %s" % songPlayed.name
		
	if canPlace: doLabelTween(placeLabel)
	if canSong:
		if canPlace: await get_tree().create_timer(2).timeout
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
