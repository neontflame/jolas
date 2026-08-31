extends Area2D
@export var levelInQuestion:String = ""
@export var whereToSpawn:String = "Spawnpoint"
var triggeredGoto:bool = false
var canGoNow:bool = false

func _enter_tree() -> void:
	triggeredGoto = false
	canGoNow = false
	await get_tree().create_timer(0.3).timeout
	canGoNow = true

func _on_body_entered(body: Node2D) -> void:
	var whereToGo:String = str(whereToSpawn)
	if not canGoNow: return
	if triggeredGoto: return
	if JolasGame.isChangingMap: return
	
	if body is PlayerObject and body == GPStats.charObject:
		print('[GoToLevel] vai ' + whereToGo)
		JolasGame.isChangingMap = true
		if body.get_multi_status():
			if not JolasGame.instance.isMenu: 
				GPStats.charObject.process_mode = Node.PROCESS_MODE_DISABLED
			print('[GoToLevel] vai')
			triggeredGoto = true
			JolasGame.instance.fadeIn(0.5, 
			func(): 
				print('[GoToLevel] ok agora volta')
				JolasGame.instance.createMap(levelInQuestion, whereToGo)
				JolasGame.instance.fadeOut(0.5)
				)
