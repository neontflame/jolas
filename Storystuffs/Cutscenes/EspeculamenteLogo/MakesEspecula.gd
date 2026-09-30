extends Node2D
class_name IntroPlaneTrail

var nodes2d:Array[Node2D] = []
var assignedLine:Dictionary[Node2D, Line2D] = {}
var initialPos:Vector2 = Vector2.ZERO
@export var framesBetweenAdd:int = 0
@export var amount:int = 4
@export var gapBetweenTrails:float = 10
var done:bool = false

func _ready() -> void:
	initialPos = global_position
	makeThings(amount, gapBetweenTrails)

func setupInitialPos():
	initialPos = global_position

func makeThings(amount:int, yGap:float):
	for i in range(amount):
		var theNode:Node2D = Node2D.new()
		add_child(theNode)
		nodes2d.append(theNode)
		theNode.position.y = yGap * i

func lineOut(mode:Array):
	# funciona assim:
	# ['B', 'B', 'c', '']
	# B e trocado pela inicial de uma cor
	# c e de *c*lear
	# string vazia nao faz nada
	var i:int = 0
	for modely in mode:
		if modely != '' and modely != 'c':
			var newLine:Line2D = Line2D.new()
			newLine.global_position = Vector2(
				0,
				nodes2d[i].position.y / 2
			)
			newLine.begin_cap_mode = Line2D.LINE_CAP_ROUND
			newLine.end_cap_mode = Line2D.LINE_CAP_ROUND
			newLine.width_curve = load("res://Storystuffs/Cutscenes/EspeculamenteLogo/CurvaNegocioNaoSei.tres")
			$Lines.add_child(newLine)
			match modely:
				'R':
					newLine.default_color = Color.CRIMSON
				'G':
					newLine.default_color = Color.LIGHT_GREEN
				'B':
					newLine.default_color = Color.DEEP_SKY_BLUE
				'Y':
					newLine.default_color = Color.GOLD
				'O':
					newLine.default_color = Color.ORANGE
				'P':
					newLine.default_color = Color.PINK
				'Pr':
					newLine.default_color = Color.WEB_PURPLE
				'Bl':
					newLine.default_color = Color.BLACK
				_:
					newLine.default_color = Color.from_string(modely, Color.WHITE)
			assignedLine[nodes2d[i]] = newLine
		elif modely == 'c':
			assignedLine[nodes2d[i]] = null
		i += 1

var elapsed:int = 0

func _physics_process(delta: float) -> void:
	if not done:
		$Lines.global_position = initialPos
	
	elapsed += 1
	
	for node in assignedLine.keys():
		if assignedLine[node]:
			var theX = node.global_position.x
			assignedLine[node].add_point(Vector2(
				theX,
				assignedLine[node].position.y + randf_range(-2, 2)
			))
			
