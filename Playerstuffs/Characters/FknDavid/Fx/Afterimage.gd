extends Node2D

var myGlobalPos:Vector2 = Vector2(0, 0)

func grabInfo(player:PlayerObject):
	$Sprite.texture = player.plySprite.sprite_frames.get_frame_texture(player.plySprite.animation, player.plySprite.frame)
	myGlobalPos = player.plySprite.global_position
	$Sprite.flip_h = player.plySprite.flip_h
	$Sprite.rotation = player.plySprite.rotation
	await get_tree().create_timer(0.25).timeout
	queue_free()

func _process(delta: float) -> void:
	global_position = myGlobalPos
