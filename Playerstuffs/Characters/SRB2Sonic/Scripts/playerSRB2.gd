extends PlayerObject

@export var special_box: CollisionShape2D

#region SRB2 Specific
var canThok: bool = true

var spinCharge := 0.0
#endregion

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func connectAttack(_stunFrames:float, fromBehind:bool = false, vel:Vector2 = Vector2(250, -250)):
	super.connectAttack(_stunFrames, fromBehind, vel)
	
func level_up():
	super.level_up()

func hitbox_connect(hit:OffensiveHitbox):
	connectAttack(2, (hitboxCoisos.scale.x == -1), Vector2(-motion.x, motion.y * -1.1 if motion.y > 0.0 and not is_on_floor() else motion.y))
