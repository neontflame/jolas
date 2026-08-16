extends "res://Levelstuffs/Mobs/StatePatternism/defaultSt.gd"

func enter_state():
	Mob.leSprite.play("default")

func update() -> void:
	var delta = get_physics_process_delta_time()
	
	if not Mob.isEnabled:
		return
	super()
	Mob.check_for_ground()
	if Mob.is_on_floor():
		if Mob.current_side == RoBawnt.sides.LEFT:
			Mob.velocity.x = move_toward(Mob.velocity.x, -Mob.MAX_SPEED, Mob.ACCELERATION * delta)
		else:
			Mob.velocity.x = move_toward(Mob.velocity.x, Mob.MAX_SPEED, Mob.ACCELERATION * delta)
			
		Mob.leSprite.flip_h = Mob.velocity.x < 0.0
