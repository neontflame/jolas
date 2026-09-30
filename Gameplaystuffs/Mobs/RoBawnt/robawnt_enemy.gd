## ele é um hawnt robô..... um roBAWNT.... fuckin epico.........
extends MobObject
class_name RoBawnt

@export_category("RoBawnt Setup")
@export var raycast_distance: float = 96.0

enum robawnt_initial_side {
	LEFT,
	RIGHT,
	RANDOM
}
@export var initial_side: robawnt_initial_side = robawnt_initial_side.RANDOM
@export_category("")

enum sides {
	LEFT,
	RIGHT
}

var current_side: sides

@export_category("Movement Detectors")
@export_group("Ground Raycasts")
@export var left_rc: RayCast2D
@export var right_rc: RayCast2D
@export var murs_rc: RayCast2D
@export_category("")

@export_category("RoBawnt Sounds")
@export var robawnt_voices: AudioStreamPlayer2D
@export_category("")

@onready var label: Label = $HawntNodes/debug_label

func _ready() -> void:
	super()
	update_rc_collision_mask(left_rc)
	update_rc_collision_mask(right_rc)
	match initial_side:
		robawnt_initial_side.LEFT:
			change_side_to(sides.LEFT)
		robawnt_initial_side.RIGHT:
			change_side_to(sides.RIGHT)
		robawnt_initial_side.RANDOM:
			var random = randi_range(0, 1)
			match random:
				1:
					change_side_to(sides.RIGHT)
				_:
					change_side_to(sides.LEFT)

func _physics_process(delta: float) -> void:
	super(delta)

func check_for_ground() -> void:
	if not is_on_floor():
		return
	
	if murs_rc.is_colliding():
		if murs_rc.get_collider() is CurvedTerrainV2 or murs_rc.get_collider() is MobObject:
			if current_side == sides.LEFT:
				change_side_to(sides.RIGHT)
			else:
				change_side_to(sides.LEFT)
		return
		
	if not left_rc.is_colliding() and current_side == sides.LEFT:
		change_side_to(sides.RIGHT)
	
	if not right_rc.is_colliding() and current_side == sides.RIGHT:
		change_side_to(sides.LEFT)

func update_rc_collision_mask(rc: RayCast2D) -> void:
	if rc.collision_mask != collision_mask:
		rc.collision_mask = collision_mask

func change_side_to(new_side: sides) -> void:
	current_side = new_side
	play_mob_sfx('fupicat_sonic_skid', 'RoBawnt')
	robawnt_voices.play()
	var modifier: float = 1.0 if current_side == sides.RIGHT else -1.0
	murs_rc.target_position.x = raycast_distance * modifier
	label.text = str(sides.keys()[current_side])
