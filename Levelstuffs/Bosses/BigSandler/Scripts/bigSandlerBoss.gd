extends BossObject
class_name BigSandler

@export_category("Sandler Specific")
@export var FUCKING_aura: AnimatedSprite2D
@export var attack_timer: Timer
@export var mini_sandler_timer: Timer
@export var projectile_target_node: Node2D
@export_group("Mini Sandler Position Markers")
@export var left_limit: Marker2D
@export var right_limit: Marker2D

var click_remote_scene = preload("uid://di3ka5pvlhhe1")
var mini_sandlers_scene = preload("uid://bicpxsxa0vmgb")

enum attack_state {
	NONE,
	THROW,
	SANDLER_WAVE,
	SANDLER_REVERT
}

signal click_clicked

var current_attack_state: attack_state = attack_state.NONE:
	set(v):
		current_attack_state = v
		match current_attack_state:
			attack_state.NONE:
				leSprite.play('default')
				attack_timer.start(3.0)
			attack_state.THROW:
				leSprite.play('clickThrow')
				attack_timer.start(3.0)
			attack_state.SANDLER_WAVE:
				leSprite.play('clickStart')
				attack_timer.start(3.0)
			attack_state.SANDLER_REVERT:
				leSprite.play('clickClick')
				mini_sandler_timer.stop()
				click_clicked.emit()
				play_boss_sfx("hl_button_10", "BigSandler", 10.0)
				attack_timer.start(3.0)

#region Default Stuff
func _ready() -> void:
	super()
	boss_signals()
	FUCKING_aura.visible = true
	leSprite.visible = false

func boss_signals() -> void:
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	mini_sandler_timer.timeout.connect(spawn_mini_sandlers)
	leSprite.frame_changed.connect(frame_specific_actions)

func _physics_process(delta: float) -> void:
	super(delta)
	if is_on_floor():
		if velocity.x != 0.0:
			velocity.x = move_toward(velocity.x, 0.0, 200.0 * delta)
#endregion

#region Sandler Content
func awake():
	JolasGame.instance.fadeBGM()
	FUCKING_aura.visible = true
	await get_tree().create_timer(2).timeout
	JolasGame.instance.playBGM(CUSTOM_BOSS_MUSIC if CUSTOM_BOSS_MUSIC != "" else "ULTRAKILLCybergrind.ogg")
	FUCKING_aura.play('entrance')
	await get_tree().create_timer(4.22).timeout
	MapUtils.map.removeEdgy()
	healthBar.visible = true
	FUCKING_aura.visible = false
	leSprite.visible = true
	change_state(state_machine.st_default)

func frame_specific_actions():
	match leSprite.animation:
		"clickThrow":
			match leSprite.frame:
				1:
					play_sfx("Thok")
					throw_click_remote()
		"clickStart":
			match leSprite.frame:
				5:
					play_boss_sfx("hl_button_3", "BigSandler", 10.0)
					mini_sandler_timer.start()

func throw_click_remote():
	var remote = click_remote_scene.instantiate() as BaseProjectile
	projectile_target_node.add_child(remote)
	remote.projectileOwner = self
	remote.launch(aim_at_player(), 20.0)
	remote.global_position = global_position

func spawn_mini_sandlers():
	var sander = mini_sandlers_scene.instantiate() as BaseProjectile
	projectile_target_node.add_child(sander)
	sander.projectileOwner = self
	sander.launch(Vector2.DOWN, 10.0)
	sander.global_position = Vector2(ms_get_random_x(), ms_get_random_y())
	click_clicked.connect(sander.go_up)

func ms_get_random_x() -> float:
	return randf_range(left_limit.global_position.x, right_limit.global_position.x)
	
func ms_get_random_y() -> float:
	return randf_range(left_limit.global_position.y, right_limit.global_position.y)

func aim_at_player() -> Vector2:
	return (GPStats.charObject.global_position - global_position).normalized()
#endregion

#region Utilities
func _on_attack_timer_timeout() -> void:
	match current_attack_state:
		attack_state.NONE:
			current_attack_state = attack_state.THROW
			return
			
		attack_state.THROW:
			current_attack_state = attack_state.SANDLER_WAVE
			return
			
		attack_state.SANDLER_WAVE:
			current_attack_state = attack_state.SANDLER_REVERT
			return
			
		attack_state.SANDLER_REVERT:
			current_attack_state = attack_state.NONE
			return
#endregion
