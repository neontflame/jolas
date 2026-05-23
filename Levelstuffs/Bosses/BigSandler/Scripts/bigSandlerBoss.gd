extends BossObject
class_name BigSandler

@export_category("Sandler Specific")
@export var FUCKING_aura: AnimatedSprite2D
@export var attack_timer: Timer
@export var projectile_target_node: Node2D

var click_remote_scene = preload("uid://di3ka5pvlhhe1")

enum attack_state {
	NONE,
	THROW,
	SANDLER_WAVE,
	SANDLER_REVERT
}

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
				attack_timer.start(3.0)

#region Default Stuff
func _ready() -> void:
	super()
	boss_signals()
	FUCKING_aura.visible = true
	leSprite.visible = false

func boss_signals() -> void:
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	leSprite.frame_changed.connect(frame_specific_actions)

func _physics_process(delta: float) -> void:
	super(delta)
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
					throw_click_remote()

func throw_click_remote():
	var remote = click_remote_scene.instantiate() as BaseProjectile
	projectile_target_node.add_child(remote)
	remote.projectileOwner = self
	remote.launch(aim_at_player(), 10.0)
	remote.global_position = global_position

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
