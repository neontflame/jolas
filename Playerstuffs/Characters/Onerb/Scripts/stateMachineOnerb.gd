extends PlayerStateMachine

@onready var hook_aim: PlayerStatePattern = $HookAim
@onready var hook_fire: PlayerStatePattern = $HookFire
@onready var hook_move: PlayerStatePattern = $HookMove
@onready var spin_attack: PlayerStatePattern = $SpinAttack
