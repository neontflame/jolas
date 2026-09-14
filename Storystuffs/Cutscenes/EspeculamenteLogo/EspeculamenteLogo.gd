extends Node2D
@export var especulaTrail:IntroPlaneTrail

var coolIntroy = [
	['', '', 'B', '', ''],
	['', 'B', '', 'B', ''],
	['B', '', '', '', 'B'],
	['c', '', '', '', 'c'],
	['', 'c', '', 'c', ''],
	['B', 'B', 'c', '', ''],
	['', '', '', '', ''],
	['', '', '', '', ''],
	['', '', '', '', ''],
	['c', '', '', '', ''],
	['', '', '', '', ''],
	['', '', '', '', ''],
	['', '', '', '', ''],
	['', '', '', '', ''],
	['', '', '', '', ''],
	['', '', '', '', ''],
	['', '', '', '', ''],
	['', '', '', '', ''],
	['', 'c', 'c', '', ''],
	['', '', '', '', '']
]

var curLine:int = -6
var gtetoPlaned:bool = false

func _physics_process(delta: float) -> void:
	if not gtetoPlaned:
		especulaTrail.position = $GTetoPlane.position
	
	if especulaTrail.elapsed % especulaTrail.framesBetweenAdd > 0:
		return
		
	if curLine < len(coolIntroy) and curLine >= 0:
		if curLine > -1:
			especulaTrail.lineOut(coolIntroy[curLine])
			print('line added:', coolIntroy[curLine], '(', curLine, ')')
		if curLine == len(coolIntroy):
			gtetoPlaned = true
			especulaTrail.done = true
		curLine += 1

func getStarted():
	curLine = 0
