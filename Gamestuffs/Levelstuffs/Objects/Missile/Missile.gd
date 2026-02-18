extends Area2D    
class_name Bullet

#You can use this signal to alert other nodes that the bullet hit something
signal hit_something

#Variable for keeping track of it's velocity
var velocity:Vector2
var cooldown := 10
var missileOwner

var used := false

#Set the velocity of the bullet
#Call this right after creating the bullet to make it start moving
func launch(direction:Vector2, speed:float):
	$objSprite.play('missile')    
	velocity = direction * speed    

#This is automatically called every physics update.
func _physics_process(delta: float) -> void:
	position += velocity
	if cooldown > 0:
		cooldown -= 1

func _on_body_entered(body):
		if used: return
		print(body.name + " entered!")
		velocity = Vector2.ZERO
		$MissileCollide.set_deferred("disabled", true)
		$objSprite.play('explode')
		$ExplosionCollide.set_deferred("disabled", false)
		
		call_deferred("fuckingExplosione")
		
func fuckingExplosione():
	print('kaboom')
	for body in get_overlapping_bodies():
		if body is PlayerObject:
			used = true
			var objHeight = $objSprite.sprite_frames.get_frame_texture('explode', 0).get_height()
			# programar na construct requer paciencia
			var distance:float = body.position.distance_to(position)
			if distance > objHeight/2: distance = objHeight/2
			
			var coolSpeeds:float = (abs(body.motion.x) + (487.5 * (0.015 * abs(objHeight/2 - distance))) * 0.75) + 50
			if abs(body.motion.x) < body.SOFT_MAX_SPEED:
				coolSpeeds = (abs(body.SOFT_MAX_SPEED) + (487.5 * (0.015 * abs(objHeight/2 - distance))) * 0.75) + 50
			
			if body.position.x > position.x:
				body.motion.x = coolSpeeds
			if body.position.x < position.x:
				body.motion.x = -coolSpeeds
			if abs(body.motion.y) < 500:
				body.motion.y = -(500 + (487.5 * (0.075 * abs(objHeight/2 - distance))) * 0.75)
			else:
				body.motion.y = -(abs(body.motion.y) + (487.5 * (0.075 * abs(objHeight/2 - distance))) * 0.75)

func _on_animation_finished() -> void:
	if $objSprite.animation == 'explode':
		queue_free()
