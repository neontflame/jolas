extends PlayerObject

#region Neon-specific
var charge:float = 0.0
var canDoCharge:bool = false
var isSpecialing:bool = false
var nonZeroXVel := 0.0
#endregion

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	# attackStrength = ATTACK_DMG['default']
	# attack = isSpecialing
	player_collisions.disabled = isSpecialing
	$SpecialCollide.disabled = !isSpecialing
	if abs(motion.x) > 2 && !is_on_wall():
		nonZeroXVel = motion.x

func handleCameraSpecial() -> void:
	$Camera2D.position.x = lerp($Camera2D.position.x, (-charge if plySprite.flip_h else charge) / 10, 0.2)
	$Camera2D.position.y = lerp($Camera2D.position.y, -motion.y / 10, 0.2)
	
	if abs(motion.x) > SOFT_MAX_SPEED * 1.25:
		idealZoom = 0.825
	else:
		idealZoom = 1
	$Camera2D.zoom = Vector2(	lerp($Camera2D.zoom.x, idealZoom, 0.05), 
								lerp($Camera2D.zoom.y, idealZoom, 0.05))

func connectAttack(_stunFrames:float, fromBehind:bool = false, vel:Vector2 = Vector2(250, -250)):
	super.connectAttack(_stunFrames, fromBehind, vel)
	if isSpecialing:
		delete_hitboxes()
		plySprite.play('specialBounceback')
		isSpecialing = false
	
func level_up():
	for key in ATTACK_DMG.keys():
		ATTACK_DMG[key] = ATTACK_DMG[key] * GPStats.level
	print('seus ataques agora sao:')
	print(ATTACK_DMG)

func hitbox_connect(hit:OffensiveHitbox):
	print('connec')
	connectAttack(2, (hitboxCoisos.scale.x == -1), Vector2(250, -250))
