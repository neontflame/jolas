extends BaseProjectile    
class_name Missile

var baseDamage := 4.0

#Set the velocity of the bullet
#Call this right after creating the bullet to make it start moving
func launch(direction:Vector2, speed:float):
	$objSprite.play('missile')
	play_sfx('Objects/Rocket')
	super.launch(direction, speed)

func before_hit():
	velocity = Vector2.ZERO
	$MissileCollide.set_deferred("disabled", true)
	$objSprite.play('explode')
	$ExplosionCollide.set_deferred("disabled", false)

func on_hit():
	# print('kaboom')
	play_sfx('Objects/RocketExplode')
	var strength:float = 243.75 + (power * 12.5 * 2)
	if strength > 500:
		strength = 500
	var objHeight = $objSprite.sprite_frames.get_frame_texture('explode', 0).get_height()

	for body in get_overlapping_bodies():
		var distance:float = body.position.distance_to(position)
		if distance > objHeight/2: distance = objHeight/2
		# BOILERPLATE INSANO
		if body is MobObject:
			if body != projectileOwner:
				if projectileOwner is PlayerObject: body.theHarmer = projectileOwner
				body.yeowch(baseDamage * power, (body.position.x > position.x))
			used = true
			var coolSpeeds:float = (abs(body.velocity.x) + (strength * (0.015 * abs(objHeight/2 - distance))) * 0.75) + 50
			if abs(body.velocity.x) < body.MAX_SPEED:
				coolSpeeds = (abs(body.MAX_SPEED) + (strength * (0.015 * abs(objHeight/2 - distance))) * 0.75) + 50
			
			if body.position.x > position.x:
				body.velocity.x = coolSpeeds
			if body.position.x < position.x:
				body.velocity.x = -coolSpeeds
			if abs(body.velocity.y) < 500:
				body.velocity.y = -(500 + (strength * (0.075 * abs(objHeight/2 - distance))) * 0.75)
			else:
				body.velocity.y = -(abs(body.velocity.y) + (strength * (0.075 * abs(objHeight/2 - distance))) * 0.75)
				
		if body is PlayerObject:
			if body != projectileOwner:
				body.yeowch(baseDamage * power, (body.position.x > position.x))
			used = true
			# programar na construct requer paciencia
			var coolSpeeds:float = (abs(body.motion.x) + (strength * (0.015 * abs(objHeight/2 - distance))) * 0.75) + 50
			if abs(body.motion.x) < body.SOFT_MAX_SPEED:
				coolSpeeds = (abs(body.SOFT_MAX_SPEED) + (strength * (0.015 * abs(objHeight/2 - distance))) * 0.75) + 50
			
			if body.position.x > position.x:
				body.motion.x = coolSpeeds
			if body.position.x < position.x:
				body.motion.x = -coolSpeeds
			if abs(body.motion.y) < 500:
				body.motion.y = -(500 + (strength * (0.075 * abs(objHeight/2 - distance))) * 0.75)
			else:
				body.motion.y = -(abs(body.motion.y) + (strength * (0.075 * abs(objHeight/2 - distance))) * 0.75)

func _on_animation_finished() -> void:
	if $objSprite.animation == 'explode':
		queue_free()
