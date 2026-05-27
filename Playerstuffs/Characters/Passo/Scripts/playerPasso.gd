extends PlayerObject

@export var wallLeftSweep:RayCast2D
@export var wallRightSweep:RayCast2D
var rebounding:bool = false
var reboundQueued:bool = false
var lastInterestingYv:float = 0.0

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if abs(motion.y) > 10:
		lastInterestingYv = motion.y

func is_wall_to_left():
	if wallLeftSweep.get_collider() is StaticBody2D:
		return true
	return false

func is_wall_to_right():
	if wallRightSweep.get_collider() is StaticBody2D:
		return true
	return false

func hitbox_connect(hit:OffensiveHitbox, type:String):
	var flipped:bool = 	Input.is_action_pressed("ctrl_left") \
						or not Input.is_action_pressed("ctrl_right") \
						and plySprite.flip_h
	
	if hit.coolId == 'rebound':
		motion.x = motion.x * 1.01
		motion.y = abs(lastInterestingYv) * -1.025
	
	if hit.coolId == 'airdash':
		state_machine.st_air.isDashing = false
		state_machine.st_air.hasDashed = false
		invulnFrames = 5.0
		jumping = false
		motion.y = -300
		plySprite.play('wallkick')
		play_char_sfx('Wallkick', 'Passo')
		
		plySprite.flip_h = flipped
		motion.x = 200 if flipped else -200
		delete_hitboxes('airdash')

func rebound_ready_animation(value: float = 5.0):
	plySprite.modulate = Color(value, value, value)
	
	var r_tween = create_tween().set_ease(
		Tween.EASE_OUT).set_trans(
			Tween.TRANS_QUART)
	r_tween.tween_property(plySprite, "modulate", Color(1.0, 1.0, 1.0), 0.2)
