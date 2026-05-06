extends Node2D

func setup(msg:String, icon:String, sound:String):
	$AudioStreamPlayer.stream = load("res://Gamestuffs/Sounds/Notifs/" + sound + ".ogg")
	$AudioStreamPlayer.play()
	$Label.text = msg
	$NinePatchRect.size = $Label.get_minimum_size() + Vector2(43 + 3, 9 + 6)
	$NinePatchRect/coolIcon.texture = load("res://Gamestuffs/HeadsUpDisplay/NotifIcons/" + icon + ".png")
	$NinePatchRect.position = Vector2(-$NinePatchRect.size.x, 0)
	await get_tree().create_timer(2).timeout
	queue_free()
