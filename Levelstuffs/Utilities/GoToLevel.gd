extends Area2D
@export var levelInQuestion:String = ""
@export var comingBack:bool = false
var triggeredGoto := false

func _enter_tree() -> void:
	triggeredGoto = false
	
func _on_body_entered(body: Node2D) -> void:
	var vai:bool = bool(comingBack)
	if triggeredGoto: return
	if body is PlayerObject:
		print('vai ' + str(comingBack))
		if body.get_multi_status():
			print('vai')
			triggeredGoto = true
			JolasGame.instance.fadeIn(0.5, 
			func(): 
				print('ok agora volta')
				JolasGame.instance.createMap(levelInQuestion)
				JolasGame.instance.respawnPlayer(false, vai)
				JolasGame.instance.fadeOut(0.5)
				)
