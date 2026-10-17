## controla bosses e fucking things oh yeah
@tool
extends Node
class_name BossController

var is_boss_fight_active: bool = false

signal boss_cutscene_started
signal boss_fight_started
signal boss_fight_finished

@export_category("Boss")
## o chefao que sera ativado nessa sala
@export var boss_object: BossObject
@export_category("")

@export_category("Components")
@export var active_at_start: bool = false
@export_category("")

@export_category("Components")
## a area que vai se passar a bossfight
@export var boss_arena_area: Area2D
## a collision shape da boss arena area
@export var boss_arena_collision: CollisionShape2D
## essa porra liga quando a boss fight começa tlg oh yeah
@export var boss_door: CurvedTerrainV2
@export_category("")

#region Boss Controller Setup
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	await get_tree().process_frame
	
	if not JolasGame.instance:
		print("jola")
		return
	
	if boss_door:
		boss_door.get_collision_polygon().set_deferred("disabled", true)
	
	await get_tree().process_frame
	
	connect_signals()
	
	check_for_active_at_start()
	
	check_for_boss_beated()

func connect_signals() -> void:
	if boss_object:
		boss_object.boss_start.connect(boss_start)
		boss_object.boss_dead.connect(boss_end)
	
	if boss_arena_area:
		boss_arena_area.body_entered.connect(on_player_entered)
	
	boss_fight_finished.connect(on_boss_fight_finished)

func check_for_boss_beated() -> void:
	if GPStats.bossesBeat.has(boss_object.name):
		boss_fight_finished.emit()
		
		if boss_object:
			boss_object.queue_free()
#endregion

#region Player Interactions
func check_for_active_at_start() -> void:
	if active_at_start:
		print("ativo no comeco")
		is_boss_fight_active = true
		boss_activate()

func on_player_entered(body: Node2D) -> void:
	if is_boss_fight_active:
		return
	
	if body is PlayerObject:
		for player in JolasGame.instance.allChars:
			if GPStats.is_multiplayer and (player.curMap != GPStats.curMap):
				return
			if not boss_arena_area.get_overlapping_bodies().has(player):
				print('[JOLASMAP] Ih crl')
				return
	
	print("JOLAS MAP boss startou")
	is_boss_fight_active = true
	boss_activate()
#endregion

#region Starting and Finishing the Boss
func boss_activate() -> void:
	boss_cutscene_started.emit()
	
	if boss_door:
		boss_door.get_collision_polygon().set_deferred("disabled", false)

func boss_start() -> void:
	boss_fight_started.emit()

func boss_end() -> void:
	# gpstats vai que é tua filhão
	GPStats.addToBossesBeat(boss_object.name)
	boss_fight_finished.emit()

func on_boss_fight_finished() -> void:
	boss_arena_collision.set_deferred("disabled", true)
	
	if boss_door:
		boss_door.get_collision_polygon().set_deferred("disabled", true)

#endregion
