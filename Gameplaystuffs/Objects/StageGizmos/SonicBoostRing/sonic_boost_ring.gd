@icon("uid://crl8ghvjkjkqn")
extends Node2D
class_name SonicBoostRing

@export_category("Setup")
@export_range(0.0, 10000.0, 16.0) var ring_strength: float = 1280.0
@export_category("")

@export_category("Components")
@export var area: Area2D
@export var area_collision: CollisionShape2D
@export var ring_sprite: Sprite2D
@export var white_ring_sprite: Sprite2D
@export var sfx: AudioStreamPlayer2D
@export_category("")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var ring_tween: Tween

func _ready() -> void:
	area.body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D) -> void:
	if body is PlayerObject:
		# animacao
		ring_tween_animation()
		
		# força o air state
		if not body.current_state == body.state_machine.st_air:
			body.change_state(body.state_machine.st_air)
		
		# vsf vc nao pode pular mais porra
		body.jumping = false
		body.jumpsDone = 99
		
		# ajusta pra posicao e aplica speed
		body.global_position = global_position
		await get_tree().process_frame
		body.motion = Vector2.UP.rotated(rotation) * ring_strength
		
		# toca o som
		sfx.play()
		sfx.pitch_scale = randf_range(0.8, 1.2)

func ring_tween_animation() -> void:
	if ring_tween and ring_tween.is_valid():
		ring_tween.kill()
	
	ring_sprite.scale = Vector2(1.5, 0.5)
	white_ring_sprite.modulate.a = 1.0
	white_ring_sprite.position.y = 0.0
	
	ring_tween = create_tween().set_parallel()
	
	ring_tween.tween_property(
		ring_sprite, "scale", Vector2.ONE, 0.25
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	
	ring_tween.tween_property(
		white_ring_sprite, "position:y", -64.0, 0.5
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	ring_tween.tween_property(
		white_ring_sprite, "modulate:a", 0.0, 0.5
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
