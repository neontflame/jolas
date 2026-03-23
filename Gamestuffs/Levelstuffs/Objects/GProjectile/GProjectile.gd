extends Area2D    
class_name GProjectile

#You can use this signal to alert other nodes that the bullet hit something
signal hit_something

#Variable for keeping track of it's velocity
var velocity:Vector2 = Vector2(0,0)
var cooldown := 10

var projectileOwner # a gente nem sequer ta usando essa variavel
var power := 1

var used := false

#Set the velocity of the bullet
#Call this right after creating the bullet to make it start moving
func launch(direction:Vector2, speed:float):
	if direction.x < 0:
		$objSprite.flip_h = true
	$objSprite.play('projectile')    
	velocity = direction * speed    

#This is automatically called every physics update.
func _physics_process(delta: float) -> void:
	position += velocity
	if cooldown > 0:
		cooldown -= 1

func _on_body_entered(body):
		if used: return
		if body == projectileOwner: return
		if body is MobObject and body.isDead: return
		print(body.name + " entered!")
		velocity = Vector2.ZERO
		$MissileCollide.set_deferred("disabled", true)
		$objSprite.play('explode')
		
		call_deferred("fuckingExplosione")
		
func fuckingExplosione():
	print('kaboom')
	var objHeight = $objSprite.sprite_frames.get_frame_texture('explode', 0).get_height()

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
				projectileOwner = JolasGame.instance.charDict[data["owner_id"]]
		if data["owner_id"] == -1:
			projectileOwner = GPStats.charObject
		pass
