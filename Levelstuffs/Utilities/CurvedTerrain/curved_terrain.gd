@tool
## Sistema de terreno curvo baseado em Path2D.[br]
## Gera automaticamente:[br]
## • Área preenchida (Polygon2D)[br]
## • Bordas com textura (Line2D)[br]
## • Colisão (CollisionPolygon2D)[br][br]
## Atualiza em tempo real no editor ao modificar a curva.
class_name CurvedTerrain
extends Path2D

#region Tool Variables
var is_platform_terrain: bool = false ## Ativa a One Way Collision, colisão de um lado para plataformas semissólidas

var enable_center_texture: bool = false: ## Habilita a textura central do terreno. Se desativado, será verde por padrão.
	set(v):
		enable_center_texture = v
		notify_property_list_changed()
		if enable_center_texture and polygon2D:
			polygon2D.texture = null
			polygon2D.texture = center_texture
			polygon2D.queue_redraw()
var center_texture: Texture2D: ## Mude a textura woah
	set(v):
		center_texture = v
		if Engine.is_editor_hint():
			call_deferred("generate_terrain")

var enable_edge_texture: bool = false: ## Habilita a textura da borda do terreno. Se desativado, será verde por padrão.
	set(v):
		enable_edge_texture = v
		notify_property_list_changed()
		if enable_edge_texture and line2D:
			line2D.queue_redraw()
var edge_texture: Texture2D: ## oooog textura custom do terreno
	set(v):
		edge_texture = v
		if Engine.is_editor_hint():
			call_deferred("generate_terrain")

enum edge_types {
	ALL_CORNERS, ## todos os cantos
	TOP, ## apenas encima
	DOWN, ## apenas embaixo
	LEFT, ## apenas na esquerda
	RIGHT ## apenas na direita
}
var current_edge_type: edge_types = edge_types.ALL_CORNERS: ## modos diferentes de textura de terreno mto legal hein ó
	set(v):
		current_edge_type = v
		if Engine.is_editor_hint():
			call_deferred("generate_terrain")
			
var edge_offset: Vector2i: ## offset da edge texture (o quao pra fora ou pra dentro ela fica lol)
	set(v):
		edge_offset = v
		if Engine.is_editor_hint():
			call_deferred("generate_terrain")

var line_texture_type: Line2D.LineTextureMode = Line2D.LineTextureMode.LINE_TEXTURE_TILE: ## ativa o stretch pra ver um negocio
	set(v):
		line_texture_type = v
		if line2D:
			line2D.texture_mode = v
		call_deferred("generate_terrain")
		
var visible_collision: bool = false: ## ve a colisao do terreno e ve se ta tudo certo blz
	set(v):
		visible_collision = v
		if collision_polygon2D:
			collision_polygon2D.visible = v
#endregion

#region Object Render Variables
var polygon2D: Polygon2D
var line2D: Line2D
var collision_polygon2D: CollisionPolygon2D

var last_curve := []
#endregion

#region Property List
func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	
	properties.append({
		"name": "Platform Terrain",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_CATEGORY
	})
	
	properties.append({
		"name": "is_platform_terrain",
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_FLAGS,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	properties.append({
			"name": "Center Texture",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_CATEGORY
		})
	
	properties.append({
			"name": "enable_center_texture",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_FLAGS,
			"usage": PROPERTY_USAGE_DEFAULT
		})
	
	if enable_center_texture:
		properties.append({
			"name": "center_texture",
			"type": TYPE_OBJECT,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "Texture2D",
			"usage": PROPERTY_USAGE_DEFAULT
		})
	
	properties.append({
			"name": "Edge Texture",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_CATEGORY
		})
	
	properties.append({
			"name": "enable_edge_texture",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_FLAGS,
			"usage": PROPERTY_USAGE_DEFAULT
		})
	
	if enable_edge_texture:
		properties.append({
			"name": "edge_texture",
			"type": TYPE_OBJECT,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "Texture2D",
			"usage": PROPERTY_USAGE_DEFAULT
		})
		
		properties.append({
			"name": "current_edge_type",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "ALL_CORNERS,TOP,DOWN,LEFT,RIGHT",
			"usage": PROPERTY_USAGE_DEFAULT
		})
		
		properties.append({
			"name": "edge_offset",
			"type": TYPE_VECTOR2I
		})
		
		properties.append({
			"name": "line_texture_type",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "None, Tile, Stretch",
			"usage": PROPERTY_USAGE_DEFAULT
		})
		
		properties.append({
			"name": "Debug Zone",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_CATEGORY
		})
		
		properties.append({
			"name": "visible_collision",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_FLAGS,
			"usage": PROPERTY_USAGE_DEFAULT
		})
	return properties
#endregion

func _ready() -> void:
	polygon2D = Polygon2D.new()
	polygon2D.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	add_child(polygon2D)
	
	line2D = Line2D.new()
	line2D.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	line2D.texture_mode = Line2D.LINE_TEXTURE_STRETCH
	add_child(line2D)
	
	var collision_staticbody: StaticBody2D = StaticBody2D.new()
	add_child(collision_staticbody)
	
	collision_polygon2D = CollisionPolygon2D.new()
	collision_staticbody.add_child(collision_polygon2D)
	
	if is_platform_terrain:
		collision_polygon2D.one_way_collision = true
	else:
		collision_polygon2D.one_way_collision = false
	
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	if curve:
		last_curve = curve.get_baked_points()
	
	generate_terrain()

#region Terrain Generation
func _process(_delta):
	if not Engine.is_editor_hint():
		return
	
	var baked = curve.get_baked_points()
	
	if not _are_points_equal(baked, last_curve):
		last_curve = baked
		generate_terrain()

func generate_terrain():
	if not curve or curve.point_count == 0:
		collision_polygon2D.polygon = []
		polygon2D.polygon = []
		line2D.points = []
		return
	
	curve.bake_interval = 32.0
	
	var points = curve.get_baked_points()
	var collider_points = curve.get_baked_points()
	
	if points.size() > 1:
		points.append(points[0])
	
	polygon2D.polygon = points
	
	if enable_center_texture and center_texture != null:
		polygon2D.texture = center_texture
	else:
		get_default_gradient(true)
	
	line2D.points = points
	
	for child in get_children():
		if child is Line2D and child != line2D:
			child.queue_free()
			
	if enable_edge_texture:
		if edge_texture:
			line2D.texture = edge_texture
			line2D.width = edge_texture.get_size().x
			line2D.default_color = Color.WHITE
			line2D.texture_mode = line_texture_type
			
			var pts = line2D.points

			# remove linhas antigas (mantém a principal se quiser debug)
			for child in get_children():
				if child is Line2D and child != line2D:
					child.queue_free()

			var segments: Array = []
			var current_segment: Array = []

			for i in range(pts.size()):
				var p = pts[i]
				
				var dir_prev: Vector2
				var dir_next: Vector2

				if i > 0:
					dir_prev = (p - pts[i - 1]).normalized()
				else:
					dir_prev = (pts[i + 1] - p).normalized()

				if i < pts.size() - 1:
					dir_next = (pts[i + 1] - p).normalized()
				else:
					dir_next = (p - pts[i - 1]).normalized()

				var dir = (dir_prev + dir_next).normalized()
				var normal = Vector2(-dir.y, dir.x)
				
				var result = get_edge_point(p, normal)
				
				if result != null:
					current_segment.append(result)
				else:
					if current_segment.size() > 1:
						segments.append(current_segment.duplicate())
					current_segment.clear()

			# adiciona último segmento
			if current_segment.size() > 1:
				segments.append(current_segment)

			# cria linhas separadas
			for segment in segments:
				var new_line := Line2D.new()
				
				new_line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
				new_line.texture = edge_texture
				new_line.width = edge_texture.get_size().x
				new_line.texture_mode = line_texture_type
				
				new_line.points = segment
				
				#if current_edge_type != edge_types.ALL_CORNERS:
					#new_line.width_curve = create_width_curve()
				
				add_child(new_line)

			# opcional: esconder a linha principal
			line2D.points = []
		else:
			get_default_line_color(true)
	else:
		get_default_line_color()
		pass
	
	if collider_points.size() > 2:
		collision_polygon2D.polygon = collider_points
	
	collision_polygon2D.visible = visible_collision
#endregion

#region Utilities
func snap_vector_to_grid(v: Vector2, grid_size: float) -> Vector2:
	return Vector2(
		round(v.x / grid_size) * grid_size,
		round(v.y / grid_size) * grid_size
	)

func _are_points_equal(a: PackedVector2Array, b: PackedVector2Array) -> bool:
	if a.size() != b.size():
		return false
	
	for i in range(a.size()):
		if a[i] != b[i]:
			return false
	
	return true
#endregion

#region Test Visuals
func get_default_gradient(is_transparent: bool = false):
	polygon2D.texture = null
	var gradient := Gradient.new()
	gradient.colors = []
	gradient.offsets = []

	var colors: Array[Color] = []
	
	if is_transparent:
		polygon2D.color = Color.WHITE

		if colors.is_empty():
			colors.append(Color.WHITE)
	else:
		polygon2D.texture = null
		polygon2D.color = Color.TRANSPARENT
		return

	var count := colors.size()

	if count == 1:
		gradient.add_point(0.0, colors[0])
		gradient.add_point(1.0, colors[0])
	else:
		var step := 1.0 / float(count - 1)
		for i in range(count):
			gradient.add_point(i * step, colors[i])

	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill = GradientTexture2D.FILL_LINEAR
	gradient_texture.fill_from = Vector2(0, 0)
	gradient_texture.fill_to = Vector2(1, 0)

	polygon2D.texture = null
	polygon2D.texture = gradient_texture

func get_default_line_color(is_transparent: bool = false):
	line2D.texture = null
	var gradient := Gradient.new()
	gradient.colors = []
	gradient.offsets = []

	var colors: Array[Color] = []
	
	if is_transparent:
		line2D.width = 1.0

		if colors.is_empty():
			colors.append(Color.WHITE)
	else:
		line2D.width = 0.0
		return

	var count := colors.size()

	if count == 1:
		gradient.add_point(0.0, colors[0])
		gradient.add_point(1.0, colors[0])
	else:
		var step := 1.0 / float(count - 1)
		for i in range(count):
			gradient.add_point(i * step, colors[i])

	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.fill = GradientTexture2D.FILL_LINEAR
	gradient_texture.fill_from = Vector2(0, 0)
	gradient_texture.fill_to = Vector2(1, 0)
	
	line2D.width = 1.0
	line2D.texture_mode = Line2D.LINE_TEXTURE_STRETCH
	line2D.texture = gradient_texture
#endregion

#region Edge Texture Type
func get_edge_point(p: Vector2, normal: Vector2) -> Variant:
	var threshold := 0.3
	
	match current_edge_type:
		edge_types.ALL_CORNERS:
			return p + normal * edge_offset.y
		
		edge_types.TOP:
			if normal.dot(Vector2.DOWN) > threshold:
				return p + normal * edge_offset.y
		
		edge_types.DOWN:
			if normal.dot(Vector2.UP) > threshold:
				return p + normal * edge_offset.y
		
		edge_types.RIGHT:
			if normal.dot(Vector2.LEFT) > threshold:
				return p + normal * edge_offset.y
		
		edge_types.LEFT:
			if normal.dot(Vector2.RIGHT) > threshold:
				return p + normal * edge_offset.y
	
	return null

func create_width_curve() -> Curve:
	var width_curve := Curve.new()
	
	var stretch = clamp(edge_offset.y / 50.0, 0.05, 0.3)
	
	width_curve.add_point(Vector2(0.0, 0.0))
	width_curve.add_point(Vector2(stretch, 1.0))
	width_curve.add_point(Vector2(1.0 - stretch, 1.0))
	width_curve.add_point(Vector2(1.0, 0.0))
	
	return width_curve
#endregion
