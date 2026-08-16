extends MobObject
class_name RoBawnt

@export_category("RoBawnt Setup")
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
@export var wall_shapecast: ShapeCast2D
@export_category("")

func _ready() -> void:
	match initial_side:
		robawnt_initial_side.LEFT:
			current_side = sides.LEFT
		robawnt_initial_side.RIGHT:
			current_side = sides.RIGHT
		robawnt_initial_side.RANDOM:
			current_side = randi_range(0, 1)
	
	super()

func _physics_process(delta: float) -> void:
	super(delta)

func check_for_ground() -> void:
	update_rc_collision_mask(left_rc)
	update_rc_collision_mask(right_rc)
	
	if not is_on_floor():
		return
	
	if wall_shapecast.is_colliding():
		return
	
	if not left_rc.is_colliding():
		change_side_to(sides.RIGHT)
	
	if not right_rc.is_colliding():
		change_side_to(sides.LEFT)

func update_rc_collision_mask(rc: RayCast2D) -> void:
	if rc.collision_mask != collision_mask:
		rc.collision_mask = collision_mask

func change_side_to(new_side: sides) -> void:
	if current_side == new_side:
		return
	current_side = new_side
