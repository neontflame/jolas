@tool
extends Node2D

var tween:Tween
var numberOfVisibles:int = 0

@export var charTalksound:DiagTalksound = null:
	set(value):
		charTalksound = value
		if is_node_ready():
			$Tickness.stream = charTalksound.talkStream

@export var rtlabel:RichTextLabel

@export_category("Trecos de audio ou algo do tipo sei laaaaa")
@export var audioStream:AudioStream:
	set(value):
		audioStream = value
		if is_node_ready():
			$Tickness.stream = audioStream

@export var volume_em_dB:float:
	set(value):
		volume_em_dB = value
		if is_node_ready():
			$Tickness.volume_db = volume_em_dB

@export var text: String = "":
	set(value):
		text = value
		if is_node_ready():
			rtlabel.text = text

func _ready() -> void:
	rtlabel.text = text
	if charTalksound:
		$Tickness.stream = charTalksound.talkStream
	else:
		$Tickness.stream = audioStream
	$Tickness.volume_db = volume_em_dB

func textUndertales(letterTime:float = 0.03):
	numberOfVisibles = 0
	rtlabel.visible_ratio = 0.0
	tween = create_tween()
	tween.tween_property(
							rtlabel, 
							"visible_ratio", 
							1.0, 
							rtlabel.get_parsed_text().length() * 0.03
							)
	tween.play()

func noUndertales():
	tween.stop()

func _physics_process(delta: float) -> void:
	if numberOfVisibles < rtlabel.visible_characters:
		if charTalksound:
			if (charTalksound.talksoundWaits and not $Tickness.playing)\
			or not charTalksound.talksoundWaits:
				$Tickness.play()
		else:
			$Tickness.play()
		numberOfVisibles = rtlabel.visible_characters
