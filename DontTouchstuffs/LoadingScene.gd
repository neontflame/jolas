extends Node2D
class_name LoadingScene

static var goToScene:String = "res://Menustuffs/Menu.tscn"
@export var loadingLabel:Label

var loading_status:int = 0.0
var progress:Array[float]

func _ready() -> void:
	loadingLabel.text = tr("loading") % ("0.0%")
	ResourceLoader.load_threaded_request(LoadingScene.goToScene)

func _process(delta: float) -> void:
	# Update the status:
	loading_status = ResourceLoader.load_threaded_get_status(LoadingScene.goToScene, progress)
	
	# Check the loading status:
	match loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			var progrers = floor(progress[0] * 10000) / 100
			loadingLabel.text = tr("loading") % (str(progrers) + "%")
		ResourceLoader.THREAD_LOAD_LOADED:
			# When done loading, change to the target scene:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(LoadingScene.goToScene))
		ResourceLoader.THREAD_LOAD_FAILED:
			print("[LOADINGSCENE] Nvm")
			get_tree().change_scene_to_file("res://DontTouchstuffs/GameInit.tscn")
