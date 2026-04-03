extends BaseProjectile    
class_name FuckingItems

var allItems:Array = ['godot', 'tetris', 'violino', 'piano']
#Set the velocity of the bullet
#Call this right after creating the bullet to make it start moving
func launch(direction:Vector2, speed:float):
	if direction.x < 0:
		$objSprite.flip_h = true
	$objSprite.play(allItems.pick_random())
	super.launch(direction, speed)

func _physics_process(delta: float) -> void:
	velocity.y += 1;
	super._physics_process(delta)
	
func _on_body_entered(body):
	if body == projectileOwner: return
	if body is MobObject and body.isDead: return
	super._on_body_entered(body)
	
	if body is StaticBody2D:
		velocity.y = abs(velocity.y) * -0.9

func after_hit():
	queue_free()
	
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
				after_hit()
		
		if body is PlayerObject:
			if body != projectileOwner:
				body.yeowch(power, (body.position.x > position.x))
			used = true
			after_hit()

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
