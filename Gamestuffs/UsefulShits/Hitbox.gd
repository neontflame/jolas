extends Area2D
class_name OffensiveHitbox

@export var collide:CollisionShape2D
var proprietor:Node2D
var damage:float = 0.0
var knockback:float = 0.0
var knockAngle:float = 0.0
# como knockangles funcionam: graus
# nos vamos assumir que:
# 0 e direita
# 90 e baixo
# 180 e esquerda
# 270 e cima
# pq dai fica melhor de fazer conta
var anglery:Vector2 = Vector2(0, 0)
var coolId:String = ''

# signal connectedHit(hit:OffensiveHitbox)

func setUp(_owner:Node2D, _scale:Vector2, _damage:float, _knockback:float, _knockAngle:float):
	proprietor = _owner
	collide.scale = _scale
	damage = _damage
	knockback = _knockback
	knockAngle = _knockAngle
	while knockAngle > 360.0:
		knockAngle -= 360.0
	while knockAngle < 0.0:
		knockAngle += 360.0
	anglery = Vector2.from_angle(deg_to_rad(knockAngle))
	
	if proprietor.has_method('hitboxes'):
		proprietor.hitboxes.append(self)
	
	set_multiplayer_authority(proprietor.get_multiplayer_authority())
		
	#if proprietor.has_method('hitbox_connect'):
		# connectedHit.connect(proprietor.hitbox_connect)

func fixAngles():
	var altAnglery:Vector2 = anglery
	altAnglery.x = anglery.x * get_parent().scale.x
	
	knockAngle = rad_to_deg(Vector2(0,0).angle_to_point(altAnglery))
	while knockAngle > 360.0:
		knockAngle -= 360.0
	while knockAngle < 0.0:
		knockAngle += 360.0

func _on_body_entered(body: Node2D) -> void:
	if body == proprietor: return
	
	var knockAngleRad = deg_to_rad(knockAngle)
	var forceCtor = Vector2(knockback * sin(knockAngleRad), knockback * cos(knockAngleRad))
	if body is PlayerObject or body is MobObject:
		if body is MobObject:
			body.theHarmer = proprietor
			if body.isDead:
				return
		var connects = body.yeowch(damage, (knockAngle < 270.0 && knockAngle > 90.0), forceCtor) #case in point
		if proprietor.has_method('hitbox_connect'): 
			if connects:
				proprietor.hitbox_connect(self)
