extends Node2D
class_name CoolMenu

static var curMenu:String = ''
static var curSelected:int = 0
static var maxSelected:int = 0

static var activeMusicLayers:int = 1
static var blurAmount:float = 0.0

static var instance:Node2D

static var comingFrom = ''

@onready var theMusics := [$BGMLayer1, $BGMLayer2, $BGMLayer3]
var theVolumes:Array = [0.0, 0.0, 0.0]

func _ready() -> void:
	CoolMenu.instance = self
	for track in theMusics:
		track.play()
		
	print(OS.get_executable_path().get_base_dir())
	
	if CoolMenu.comingFrom != '':
		$MainMenu.change_self_scene('res://Menustuffs/' + comingFrom + '/' + comingFrom + '.tscn')
		CoolMenu.comingFrom = ''

var sineWaveCoolio := 0.0

func _process(delta: float) -> void:
	sineWaveCoolio += delta/8.0
	$MenuBg.position.x = (sin(sineWaveCoolio) * (96.0/2.0)) + 354.0
	
	$BlurFx.material.set_shader_parameter("amount", lerp($BlurFx.material.get_shader_parameter("amount"), blurAmount, 0.2))
	
	for vol in range(len(theMusics)):
		if vol < CoolMenu.activeMusicLayers:
			# print('Get N')
			theVolumes[vol] = 0.0
		else:
			# print('Get out')
			theVolumes[vol] = -1000.0
	# print(CoolMenu.activeMusicLayers, ' music layers, ', theVolumes)
	
	for trackNum in range(len(theMusics)):
		theMusics[trackNum].volume_db = lerp(theMusics[trackNum].volume_db, theVolumes[trackNum], 0.2)

static func play_sfx(sfxName:String):
	if !CoolMenu.instance: return
	CoolMenu.instance.get_node('SFX/' + sfxName).play()
	
static func stop_sfx(sfxName:String):
	if !CoolMenu.instance: return
	CoolMenu.instance.get_node('SFX/' + sfxName).stop()
