extends PlayerObject

@export_category("Espy Specific Thingies")
@export var bolha_sprite: Sprite2D
@export var setaralho: Sprite2D

var bubble_blasted: bool = false
var can_bubble_blast: bool = true

var bubble_aim: Vector2

func _ready() -> void:
	super()
	bolha_sprite.scale = Vector2.ZERO
	setaralho.modulate.a = 0.0

func _physics_process(delta: float) -> void:
	super(delta)
	print(coolCamera.offset)

func bubble_aim_camera():
	coolCamera.offset = lerp(coolCamera.offset, bubble_aim.normalized() * 200.0, 0.1)

func can_activate_bubble():
	if Input.is_action_just_pressed("ctrl_2") and can_bubble_blast:
		can_bubble_blast = false
		change_state(state_machine.st_bubbleaim)

func rotate_arrow_based_on_input():
	var input = Input.get_vector("ctrl_left", "ctrl_right", "ctrl_up", "ctrl_down")
	if input != Vector2.ZERO:
		bubble_aim = input
