@tool
extends BossController

@export_category("Sandler Shits")
@export var creepy_bg: SS2D_Shape
@export_category("")

var creepy_tween: Tween

func boss_activate() -> void:
	super()
	boss_object.awake()

func boss_start() -> void:
	super()
	kill_creepy_tween()
	creepy_tween = create_tween()
	creepy_tween.tween_property(creepy_bg, "modulate:a", 0.5, 1.0)

func boss_end() -> void:
	super()
	kill_creepy_tween()
	creepy_tween = create_tween()
	creepy_tween.tween_property(creepy_bg, "modulate:a", 0.0, 1.0)

func kill_creepy_tween() -> void:
	if creepy_tween and creepy_tween.is_valid():
		creepy_tween.kill()
