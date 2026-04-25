@tool
extends Node2D
class_name MolaQuadradaDoKiko

@export_category("SpringSetup")
@export_range(0.0, 10000.0) var spring_strength: float = 1000.0:
	set(v):
		spring_strength = v
		queue_redraw()

@export_range(0.1, 2.0) var spring_speed: float = 1.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export_category("Tech Stuff")
@export var player_position: Marker2D
@export var spring_sound: AudioStreamPlayer2D

var current_object: CharacterBody2D

func _ready() -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	animation_player.speed_scale = spring_speed

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	draw_line(player_position.position, (player_position.position + spring_strength * Vector2.UP) * 0.75, Color.GREEN, 8.0)

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if current_object:
		if current_object is PlayerObject:
			current_object.motion = Vector2.ZERO
			current_object.global_position = (player_position.global_position - Vector2(0.0, (current_object.player_collisions.shape.size.y) / 2).rotated(rotation))
		elif current_object is MobObject:
			current_object.velocity = Vector2.ZERO
			current_object.global_position = (player_position.global_position - Vector2(0.0, (current_object.collisions.shape.size.y) / 2).rotated(rotation))

func _on_area_2d_body_entered(body: Node2D) -> void:
	if Engine.is_editor_hint():
		return
	if current_object == null and not animation_player.is_playing():
		if body is PlayerObject:
			current_object = body
			current_object.walkingEnabled = false
			animation_player.play("mola_quadrada_do_kiko/boingoing")
		if body is MobObject:
			current_object = body
			animation_player.play("mola_quadrada_do_kiko/boingoing")

func release_player():
	if not current_object or Engine.is_editor_hint():
		return
	play_sfx(spring_sound)
	
	if current_object:
		if current_object is PlayerObject:
			current_object.motion = spring_strength * Vector2.UP.rotated(rotation)
			current_object.walkingEnabled = true
			current_object.change_state(current_object.state_machine.st_air)
			current_object = null
		elif current_object is MobObject:
			current_object.velocity = spring_strength * Vector2.UP.rotated(rotation)
			current_object = null

func play_sfx(sfx: AudioStreamPlayer2D):
	sfx.volume_db = GeneralUtils.get_volume_db('sfx')
	sfx.play()
	sfx.pitch_scale = randf_range(0.8, 1.2)
