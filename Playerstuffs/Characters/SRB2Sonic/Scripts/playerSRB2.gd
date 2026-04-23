extends PlayerObject

#region SRB2 Specific
var canThok: bool = true

var spinCharge := 1000.0

@export var special_box: CollisionShape2D
@export var spinFxTimer: Timer
var squash_tween: Tween

var thokFx = preload("res://Playerstuffs/Characters/SRB2Sonic/Fx/ThokFX.tscn")

#endregion

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if current_state == state_machine.st_hurt:
		set_roll_collision(false)
	
	special_box.rotation = practicalAngle

func connectAttack(_stunFrames:float, fromBehind:bool = false, vel:Vector2 = Vector2(250, -250)):
	super.connectAttack(_stunFrames, fromBehind, vel)
	
func level_up():
	super.level_up()

func hitbox_connect(hit:OffensiveHitbox):
	connectAttack(2, true, spin_knockback())

func set_roll_collision(setter: bool):
	special_box.set_deferred("disabled", not setter)
	player_collisions.set_deferred("disabled", setter)

func spin_knockback() -> Vector2:
	var x_value: float
	var y_value: float
	
	x_value = motion.x
	
	if is_on_floor():
		y_value = motion.y
	else:
		if motion.y > 0:
			if Input.is_action_pressed("ctrl_jump"):
				y_value = motion.y * -1.1
			else:
				y_value = -400.0
		else:
			y_value = motion.y
	
	return Vector2(x_value, y_value)

func create_thok_fx():
	var tfx = thokFx.instantiate() as Sprite2D
	get_parent().add_child(tfx)
	tfx.global_position = self.global_position
	tfx.offset = self.plySprite.offset
	tfx.rotation = practicalAngle

func generic_squish(is_vertical: bool = true):
	
	if is_vertical:
		plySprite.scale = Vector2(0.5, 1.5)
	else:
		plySprite.scale = Vector2(1.5, 0.5)
	if squash_tween and squash_tween.is_valid(): squash_tween.kill()
	squash_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	squash_tween.tween_property(plySprite, "scale", Vector2.ONE, 0.5)


func _on_spin_fx_timer_timeout() -> void:
	create_thok_fx()
