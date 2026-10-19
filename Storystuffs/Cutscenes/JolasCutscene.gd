extends Node2D
class_name JolasCutscene

signal cutsceneEnd # emite quando quiser bro
signal cutsceneStart

func _ready() -> void:
	cutsceneStart.emit()
