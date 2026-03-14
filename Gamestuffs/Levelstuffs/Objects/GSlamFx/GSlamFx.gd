extends Area2D    
class_name GSlamFx

#You can use this signal to alert other nodes that the bullet hit something
signal hit_something

var fxOwner # a gente nem sequer ta usando essa variavel
var power := 5
var knockLocity = Vector2(200, -500)

func _enter_tree() -> void:
	$AnimatedSprite2D.play("default")
#This is automatically called every physics update.
#func _physics_process(delta: float) -> void:
	#position += velocity
	#if cooldown > 0:
		#cooldown -= 1

func _on_body_entered(body):
		if body == fxOwner: return
		print(body.name + " entered!")
		call_deferred("crossfire")
		
func crossfire():
	print('yeouch')
	for body in get_overlapping_bodies():
		if body is MobObject:
			if body != fxOwner:
				if fxOwner is PlayerObject: 
					body.theHarmer = fxOwner
				body.yeowch(power, (body.position.x > position.x), knockLocity)
		
		if body is PlayerObject:
			if body != fxOwner:
				body.yeowch(power, (body.position.x > position.x), knockLocity)

func _on_animation_finished() -> void:
	queue_free()

func apply_additional_data(data: Dictionary):
	if data.has("velocity"):
		knockLocity = data.velocity
	if data.has("power"):
		power = data.power
	if data.has("owner_id"):
		if GPStats.is_multiplayer:
			if (JolasGame.instance.charDict.has(data["owner_id"])):
				fxOwner = JolasGame.instance.charDict[data["owner_id"]]
		if data["owner_id"] == -1:
			fxOwner = GPStats.charObject
		pass
