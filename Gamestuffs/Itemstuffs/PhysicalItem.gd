extends BaseProjectile    
class_name PhysicalItem

@export var associatedItem:String = ""
@export var maxLifetime = 4.0

func _enter_tree() -> void:
	await get_tree().create_timer(maxLifetime).timeout
	fadeAway()


func _physics_process(delta: float) -> void:
	velocity.y += 1;
	super._physics_process(delta)
	
	if $RWallCast.collide_with_bodies \
	and $RWallCast.get_collider() is StaticBody2D:
		velocity.x = abs(velocity.x) * -1
		position.x -= 12
		
	if $LWallCast.collide_with_bodies \
	and $LWallCast.get_collider() is StaticBody2D:
		velocity.x = abs(velocity.x)
		position.x += 12
		
	if $CeilCast.collide_with_bodies \
	and $CeilCast.get_collider() is StaticBody2D:
		velocity.y = abs(velocity.y)
		position.y += 3
	
	for body in get_overlapping_bodies():
		if body == GPStats.charObject:
			if Input.is_action_just_pressed("ctrl_interact"):
				GPStats.charObject.play_sfx('Pop')
				InventoryUtils.add_to_inventory(associatedItem)
				queue_free()
		if body is StaticBody2D:
			velocity.y = abs(velocity.y) * -0.3
			position.y -= 4
	
func _on_body_entered(body):
	super._on_body_entered(body)
	
func on_hit():
	pass

func fadeAway():
	var cooltweenie = get_tree().create_tween()
	cooltweenie.tween_method(
		func(v):
			if $objSprite:
				$objSprite.self_modulate.a = v
			if v <= 0.01:
				queue_free(),
			1.0, 0.0, 1.0)
