@tool
extends BossController

func boss_activate() -> void:
	super()
	boss_object.awake()
