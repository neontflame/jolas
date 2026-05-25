@tool
extends Node2D
class_name MolaQuadradaDoKiko

@export_category("SpringSetup")
@export_range(0.0, 10000.0) var launch_force: float = 1000.0:
	set(v):
		launch_force = v
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
	var preview_size := launch_force * 0.35

	draw_line(
		player_position.position,
		player_position.position + get_launch_direction() * preview_size,
		Color.GREEN,
		8.0
	)

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
	
	if current_object is PlayerObject:
		current_object.motion = get_launch_velocity(current_object)
		current_object.walkingEnabled = true
	
	elif current_object is MobObject:
		current_object.velocity = get_launch_velocity(current_object)
	
	current_object = null

#region Utilities
func get_launch_direction() -> Vector2:
	return Vector2.UP.rotated(rotation)

func get_launch_velocity(body) -> Vector2:
	var gravity_ratio: float = 25.0 / body.GRAVITY
	var gravity_modifier: float = pow(gravity_ratio, 0.35)

	return get_launch_direction() * launch_force * gravity_modifier

func play_sfx(sfx: AudioStreamPlayer2D):
	sfx.volume_db = GeneralUtils.get_volume_db('sfx')
	sfx.play()
	sfx.pitch_scale = randf_range(0.8, 1.2)
#endregion
