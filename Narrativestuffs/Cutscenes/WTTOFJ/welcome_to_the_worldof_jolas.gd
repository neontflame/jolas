extends Control
class_name WelcomeToTheWorldOfJolas

@export_category("Components")
@export var music: AudioStreamPlayer
@export var text_area: Control
@export var black_bg_label: Label
@export_category("")

func _ready() -> void:
	music.finished.connect(on_song_finished)

func welcome() -> void:
	text_area.position.y = 16.0
	black_bg_label.text ="""welcome to the
	world of JOLAS."""
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_property(text_area, "position", Vector2.ZERO, 3.0)

func on_song_finished() -> void:
	pass
