extends BaseProjectile    
class_name BSSandler

@export var sandler_sprite: AnimatedSprite2D
@export var sand_collision: CollisionShape2D
var knockVel:Vector2 = Vector2(250, -250)

func _on_body_entered(body):
	if body == projectileOwner: return
	if (body is MobObject or body is BossObject) and body.isDead: return
	super._on_body_entered(body)

func before_hit():
	velocity = Vector2.ZERO
	sand_collision.set_deferred("disabled", true)
	sandler_sprite.play('explode')

func on_hit():
	for body in get_overlapping_bodies():
		# BOILERPLATE INSANO
		if body is MobObject or body is BossObject:
			if not body.isDead:
				if body != projectileOwner:
					if projectileOwner is PlayerObject: 
						body.theHarmer = projectileOwner
					var thisKnockVel:Vector2 = knockVel
					if body.position.x < position.x:
						thisKnockVel.x *= -1
					body.yeowch(power, thisKnockVel)
				used = true
		
		if body is PlayerObject:
			if body != projectileOwner:
				var thisKnockVel:Vector2 = knockVel
				if body.position.x < position.x:
					thisKnockVel.x *= -1
				body.yeowch(power, thisKnockVel)
			used = true

func on_area_entered(area: Area2D):
	pass

func _on_animation_finished() -> void:
	if sandler_sprite.animation == 'explode':
		queue_free()

func go_up():
	if used:
		return
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "velocity", -velocity, 3.0)
