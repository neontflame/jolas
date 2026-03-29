extends PlayerObject

#region Neon-specific
var charge:float = 0.0
var canDoCharge:bool = false

var isSpecialing:bool = false
var nonZeroXVel := 0.0
#endregion

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	player_collisions.disabled = isSpecialing
	$SpecialCollide.disabled = !isSpecialing
	if abs(motion.x) > 2 && !is_on_wall():
		nonZeroXVel = motion.x

func handleCameraSpecial() -> void:
	super.handleCamera()
	$Camera2D.position.x = lerp($Camera2D.position.x, (-charge if plySprite.flip_h else charge) / 10, 0.2)

func connectAttack(_stunFrames:float, fromBehind:bool = false, vel:Vector2 = Vector2(250, -250)):
	super.connectAttack(_stunFrames, fromBehind, vel)
	if isSpecialing:
		delete_hitboxes()
		plySprite.play('specialBounceback')
		isSpecialing = false
	
func level_up():
	super.level_up()

func hitbox_connect(hit:OffensiveHitbox):
	# print('connec')
	connectAttack(2, (hitboxCoisos.scale.x == -1), Vector2(250, -250))
