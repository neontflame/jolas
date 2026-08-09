extends Node2D
class_name LoadingScene

static var goToScene:String = "res://Menustuffs/Menu.tscn"

var loading_status:int
var progress:Array[float]

func _ready() -> void:
	ResourceLoader.load_threaded_request(LoadingScene.goToScene)

func _process(delta: float) -> void:
	# Update the status:
	loading_status = ResourceLoader.load_threaded_get_status(LoadingScene.goToScene, progress)
	
	# Check the loading status:
	match loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			$Label3.text = "Carregando (%s)" % (str(progress[0] * 100) + "%")
		ResourceLoader.THREAD_LOAD_LOADED:
			# When done loading, change to the target scene:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(LoadingScene.goToScene))
		ResourceLoader.THREAD_LOAD_FAILED:
			print("Nvm")
			get_tree().change_scene_to_file("res://DontTouchstuffs/GameInit.tscn")
