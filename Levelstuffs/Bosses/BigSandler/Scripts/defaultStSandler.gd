extends "res://Levelstuffs/Bosses/StatePatternism/defaultSt.gd"

var isAttacking:bool = false

func update():
	super.update()
	if not isAttacking:
		attackClick()

func attackClick():
	isAttacking = true
	Boss.leSprite.play('clickStart')
	await get_tree().create_timer(3).timeout
	Boss.leSprite.play('clickClick')
	await get_tree().create_timer(1).timeout
	Boss.leSprite.play('clickThrow')
	await get_tree().create_timer(0.5).timeout
	isAttacking = false
