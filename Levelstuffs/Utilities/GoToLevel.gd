extends Area2D
@export var levelInQuestion:String = ""
@export var whereToSpawn:String = "Spawnpoint"
var triggeredGoto := false
var canGoNow = false

func _enter_tree() -> void:
	triggeredGoto = false
	await get_tree().create_timer(0.05).timeout
	canGoNow = true

func _on_body_entered(body: Node2D) -> void:
	var whereToGo:String = str(whereToSpawn)
	if not canGoNow: return
	if triggeredGoto: return
	if body is PlayerObject:
		print('vai ' + whereToGo)
		if body.get_multi_status():
			if not JolasGame.instance.isMenu: GPStats.charObject.process_mode = Node.PROCESS_MODE_DISABLED
			print('vai')
			triggeredGoto = true
			JolasGame.instance.fadeIn(0.5, 
			func(): 
				print('ok agora volta')
				JolasGame.instance.createMap(levelInQuestion)
				JolasGame.instance.respawnPlayer(false, whereToGo)
				JolasGame.instance.fadeOut(0.5)
				if not JolasGame.instance.isMenu: GPStats.charObject.process_mode = Node.PROCESS_MODE_INHERIT
				)
