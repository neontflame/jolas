@tool
@icon("uid://c33sc3mggdipf")
extends JolasMap
class_name JolasMapBoss

@export var bossController:BossController

@export var spawnpoint:Node2D
@export var spawnpointInBoss:Node2D

var spawnPosShit:Dictionary = {}

func setUpSignals():
	bossController.boss_fight_started.connect(bossStart)
	bossController.boss_fight_finished.connect(bossFinish)
	bossController.boss_fight_already_beaten.connect(bossAlreadyBeaten)

func _ready() -> void:
	super._ready()
	
	if spawnpoint and spawnpointInBoss:
		spawnPosShit["normal"] = spawnpoint.position
		spawnPosShit["boss"] = spawnpointInBoss.position
	setUpSignals()

func bossStart():
	if not spawnPosShit.is_empty():
		spawnpoint.position = spawnPosShit["boss"]

func bossFinish():
	if not spawnPosShit.is_empty():
		spawnpoint.position = spawnPosShit["normal"]

func bossAlreadyBeaten():
	bossFinish()
