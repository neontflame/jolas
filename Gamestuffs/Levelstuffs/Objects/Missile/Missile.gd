extends Area2D    
class_name Bullet

#You can use this signal to alert other nodes that the bullet hit something
signal hit_something

#Variable for keeping track of it's velocity
var velocity:Vector2 = Vector2(0,0)
var cooldown := 10

var missileOwner # a gente nem sequer ta usando essa variavel
var power := 1

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
			var strength:float = 243.75 + (power * 12.5 * 2)
			if strength > 500:
				strength = 500
				
			if body != missileOwner:
				body.yeowch(2 * power, (body.position.x > position.x))
			used = true
			var objHeight = $objSprite.sprite_frames.get_frame_texture('explode', 0).get_height()
			# programar na construct requer paciencia
			var distance:float = body.position.distance_to(position)
			if distance > objHeight/2: distance = objHeight/2
			
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

func apply_additional_data(data: Dictionary):
	if data.has("direction") and data.has("speed"):
		launch(data.direction, data.speed)
	if data.has("rotation"):
		rotation = data.rotation
	if data.has("power"):
		power = data.power
	if data.has("owner_id"):
		if GPStats.is_multiplayer:
			if (JolasGame.instance.charDict.has(data["owner_id"])):
				missileOwner = JolasGame.instance.charDict[data["owner_id"]]
		if data["owner_id"] == -1:
			missileOwner = GPStats.charObject
		pass
