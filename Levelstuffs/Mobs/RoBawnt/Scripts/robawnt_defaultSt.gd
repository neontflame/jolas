extends "res://Levelstuffs/Mobs/StatePatternism/defaultSt.gd"

func enter_state():
	Mob.leSprite.play("default")

func update() -> void:
	if not Mob.isEnabled:
		return
	super()
	Mob.check_for_ground()
	if Mob.current_side == RoBawnt.sides.LEFT:
		Mob.velocity.x = -Mob.MAX_SPEED
		print("andando pra esquerda")
	else:
		Mob.velocity.x = Mob.MAX_SPEED
		print("andando pra direita")
