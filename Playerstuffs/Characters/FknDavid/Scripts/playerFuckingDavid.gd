extends PlayerObject

var itemCooldown:float = 0.0
var dashCooldown:float = 0.0

@export var dashSpeed:float = 350.0
@export var dashAttenuate:float = 0.75
@export var itemCooldownSecs:float = 0.5

var dashTriggered:bool = false

#region Trecos que eu copiei da gteto ebaaaaaaaaa
var yChange := -0.875
var projPos := Vector2(40.0, -7.0)
#endregion

func _process(_delta: float) -> void:
	if dashCooldown > 0:
		dashCooldown -= deltaOne
	
	if itemCooldown > 0:
		itemCooldown -= deltaOne
	
	if dashTriggered and is_on_floor():
		dashTriggered = false

func handleMovement():
	super.handleMovement()
	if movementEnabled:
		if Input.is_action_just_pressed("ctrl_1"):
			print(dashCooldown)
			if dashCooldown <= 0 and not dashTriggered:
				change_state(state_machine.st_dash)
				dashTriggered = true
				dashCooldown = 24.0
		if Input.is_action_pressed("ctrl_2"):
			throwEm()

func throwEm():
	if itemCooldown > 0: return
	itemCooldown = itemCooldownSecs * 60.0 # so pra nao ficar spammy demais
	motion.x *= 0.3
	play_sfx('Whoosh')
	plySprite.play('useItem')
	plySprite.set_frame_and_progress(0, 0.0)
	await get_tree().create_timer(0.05).timeout
	var dirMultiplier = (-1.0 if plySprite.flip_h else 1.0)
	var coolDir = Vector2(dirMultiplier, yChange).rotated(practicalAngle)
	var coolPos:Vector2 = position + Vector2(projPos.x * dirMultiplier, projPos.y).rotated(practicalAngle)
	var params:Dictionary = {
		"direction": coolDir,
		"speed": 12.0 + abs(motion.x * 1/120),
		"power": ATTACK_DMG_LVL['default'],
		"owner_id": playerID
	}
	MapUtils.spawn_object('FuckingItems', 
						coolPos, 
						"Default", 
						params)

func velToVector(speed:float, vectorDir:Vector2):
	if vectorDir.x < 0 && -speed < motion.x \
	or vectorDir.x > 0 && speed > motion.x :
		motion.x = speed * vectorDir.x
	else:
		motion.x += speed * vectorDir.x * dashAttenuate
		
	if vectorDir.x == 0: motion.x = 0
	if vectorDir.y == 0: motion.y = 0
	
	if vectorDir.y < 0 && -speed < motion.y \
	or vectorDir.y > 0 && speed > motion.y :
		motion.y = speed * vectorDir.y
	else:
		motion.x += speed * vectorDir.y * dashAttenuate

func makeAfterimage():
	var afterimg = GameUtils.get_char_asset("FknDavid", "Fx/Afterimage.tscn").instantiate()
	add_child(afterimg)
	afterimg.grabInfo(self)

func hitbox_connect(hit:OffensiveHitbox):
	# print('connec')
	connectAttack(5.0, (hitboxCoisos.scale.x == -1))
	
