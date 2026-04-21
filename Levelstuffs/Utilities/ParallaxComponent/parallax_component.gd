@tool
extends ParallaxBackground

## Referência para a ParallaxLayer usada no efeito.
## Necessária para configurar repetição (motion_mirroring).
@export var PLayer: ParallaxLayer

## Sprite usado para scroll manual da textura (modo MOBILE).
@export var Sprite: Sprite2D


## Define o tipo de comportamento do parallax:
## STATIC = fundo parado
## MOBILE = scroll manual da textura
## DYNAMIC = usa scroll_base_scale
## MOBILE_DYNAMIC = mistura os dois
enum Types {
	STATIC,
	MOBILE,
	DYNAMIC,
	MOBILE_DYNAMIC
}

var _parallax_type = Types.STATIC

## Tipo atual do parallax.
## Controla quais propriedades aparecem no Inspector.
var ParallaxType:
	get:
		return _parallax_type
	set(value):
		_parallax_type = value
		if Sprite:
			Sprite.region_rect.position = Vector2.ZERO
		notify_property_list_changed()

## Velocidade do scroll manual da textura.
## Usado em MOBILE e MOBILE_DYNAMIC.
var ScrollSpeed: Vector2

## Velocidade do parallax dinâmico.
## Usado em DYNAMIC e MOBILE_DYNAMIC.
var DynamicScrollSpeed: Vector2


## Define se o scroll pode passar de zero.
## (Reservado para uso futuro)
var can_go_below_zero: bool = false


func _get_property_list() -> Array:
	var Configs: Array = []
	
	Configs.append({
		"name": "ParallaxType",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "STATIC, MOBILE, DYNAMIC, MOBILE_DYNAMIC",
		"usage": PROPERTY_USAGE_DEFAULT
	})
	
	## Só aparece quando há movimento manual
	if is_mobile():
		Configs.append({
			"name": "ScrollSpeed",
			"type": TYPE_VECTOR2,
			"usage": PROPERTY_USAGE_DEFAULT
		})

	## Só aparece quando há movimento dinâmico
	if is_dynamic():
		Configs.append({
			"name": "DynamicScrollSpeed",
			"type": TYPE_VECTOR2,
			"usage": PROPERTY_USAGE_DEFAULT
		})

	return Configs


func _ready() -> void:
	## Desativa o parallax padrão nesses modos
	match ParallaxType:
		Types.STATIC, Types.MOBILE, Types.MOBILE_DYNAMIC:
			scroll_base_scale = Vector2(0, 0)


func _process(delta: float) -> void:
	## Scroll manual da textura
	if is_mobile():
		if PLayer and Sprite:
			PLayer.motion_mirroring = Sprite.region_rect.size
		else:
			print("ParallaxLayer não configurado!")

		if Sprite:
			Sprite.region_rect.position += ScrollSpeed * delta
		else:
			print("Sprite não configurado!")

	## Scroll baseado no sistema da engine
	if is_dynamic():
		if PLayer and Sprite:
			PLayer.motion_mirroring = Sprite.region_rect.size
			scroll_base_scale = DynamicScrollSpeed
		else:
			print("ParallaxLayer não configurado!")

## Retorna true se usa scroll manual
func is_mobile():
	return ParallaxType == Types.MOBILE or ParallaxType == Types.MOBILE_DYNAMIC

## Retorna true se usa scroll dinâmico
func is_dynamic():
	return ParallaxType == Types.DYNAMIC or ParallaxType == Types.MOBILE_DYNAMIC
