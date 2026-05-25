@tool
@icon("uid://dyd0sa3a2ecf7")
extends StaticBody2D
class_name CurvedTerrainV2

## Crie pisos pisáveis com isso! Não precisa ser filho de um StaticBody... porque isso é um StaticBody.
## [url=https://youtu.be/45PldDNCQhw?si=VBgYKlf8lRlOMRWK]Confira o tutorial para mais detalhes de como usar a SmartShape2D.[/url]

## Debug Cracks
@export var visible_collision: bool = false:
	set(v):
		visible_collision = v
		update_platform()

enum types {
	REGULAR, ## Padrão, sem nada demais.
	PLATFORM, ## Plataforma semissólida, ativa o One Way Collision do Collision Polygon filho (quando tiver um)
	RED, ## Apenas se o player tiver colisão com a camada 3 ligada, excelente para loops!
	BLUE ## Apenas se o player tiver colisão com a camada 4 ligada, excelente para loops!
}

## Qual o tipo de terreno.
@export var terrain_type: types = types.REGULAR:
	set(v):
		terrain_type = v
		update_platform()

@export_tool_button("Gerar Smart Shape", "SphereShape3D")
var update_action = create_ss2d

@export_group("Ignore this. Please.")
@export var obj_shape: SS2D_Shape ## só remova isso aqui se não tiver mais um smart shape 2d como filho do node

func _ready() -> void:
	update_platform()
	child_entered_tree.connect(check_for_collision)

func create_ss2d() -> void:
	if obj_shape:
		print("Shape already generated.")
		if not obj_shape.points_modified.is_connected(update_platform):
			obj_shape.points_modified.connect(update_platform)
		return
	var new_shape = SS2D_Shape.new()
	add_child(new_shape)
	
	new_shape.owner = get_tree().edited_scene_root
	new_shape.name = "SS2D_Shape"
	obj_shape = new_shape
	obj_shape.points_modified.connect(update_platform)

func check_for_collision(node: Node):
	if node is CollisionPolygon2D:
		update_platform()
	
	if node is SS2D_Shape:
		if not obj_shape:
			obj_shape = node

func update_platform() -> void:
	setup_collision_layers() # get the thing
	
	# then the curve.
	modulate_based_on_layer()
	
	# then the collision
	if Engine.is_editor_hint():
		var collision: CollisionPolygon2D = get_collision_polygon()

		if not collision:
			print("Please finish your terrain and generate your collision first.")
			return
		
		collision.set_meta("_edit_lock_", true)
		
		if terrain_type == types.PLATFORM:
			collision.one_way_collision = true
			collision.one_way_collision_margin = 32.0
		else:
			collision.one_way_collision = false
		
		collision.visible = visible_collision

func get_collision_polygon() -> CollisionPolygon2D:
	for child in get_children():
		if child is CollisionPolygon2D:
			return child
	
	return null

func setup_collision_layers() -> void:
	match terrain_type:
		types.RED:
			collision_layer = (1 << 2)
			collision_mask = (1 << 2)
		types.BLUE:
			collision_layer = (1 << 3)
			collision_mask = (1 << 3)
		_:
			collision_layer = (1 << 0)
			collision_mask = (1 << 0)

func modulate_based_on_layer():
	if not obj_shape:
		return
	if not Engine.is_editor_hint():
		obj_shape.modulate = Color.WHITE
		return
		
	match terrain_type:
		types.PLATFORM:
			obj_shape.modulate = Color.PURPLE
		types.RED:
			obj_shape.modulate = Color.RED
		types.BLUE:
			obj_shape.modulate = Color.BLUE
		_:
			obj_shape.modulate = Color.WHITE
