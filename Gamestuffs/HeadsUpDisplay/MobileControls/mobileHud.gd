extends Node

func _ready() -> void:
	$MobileTopRight/ChatButton.visible = GPStats.is_multiplayer
