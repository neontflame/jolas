extends JolasCutscene
@export var vidStreamPly:VideoStreamPlayer

func playVid(video:String):
	vidStreamPly.stream = load("res://Storystuffs/Cutscenes/VideoCutscene/Videos/%s.ogv" % video)
	vidStreamPly.play()
	print("[VIDEOCUTSCENE] tocando vid")

func onStreamFinished() -> void:
	cutsceneEnd.emit()
