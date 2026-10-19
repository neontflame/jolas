@tool
extends JolasMap

func _ready() -> void:
	await get_tree().process_frame
	if JolasGame.instance and (not isOnCutscene):
		if JolasGame.instance.mapExploredForFirstTime:
			JolasGame.instance.startVideoCutscene("testbench")
	
	super._ready()
