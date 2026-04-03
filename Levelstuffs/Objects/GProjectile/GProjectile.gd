extends BaseProjectile    
class_name GProjectile

#Set the velocity of the bullet
#Call this right after creating the bullet to make it start moving
func launch(direction:Vector2, speed:float):
	if direction.x < 0:
		$objSprite.flip_h = true
	$objSprite.play('projectile')
	super.launch(direction, speed)

func _on_body_entered(body):
	if body == projectileOwner: return
	if body is MobObject and body.isDead: return
	super._on_body_entered(body)

func before_hit():
	velocity = Vector2.ZERO
	$MissileCollide.set_deferred("disabled", true)
	$objSprite.play('explode')

func on_hit():
	for body in get_overlapping_bodies():
		# BOILERPLATE INSANO
		if body is MobObject:
			if not body.isDead:
				if body != projectileOwner:
					if projectileOwner is PlayerObject: 
						body.theHarmer = projectileOwner
					body.yeowch(power, (body.position.x > position.x))
				used = true
		
		if body is PlayerObject:
			if body != projectileOwner:
				body.yeowch(power, (body.position.x > position.x))
			used = true

func _on_animation_finished() -> void:
	if $objSprite.animation == 'explode':
		queue_free()
