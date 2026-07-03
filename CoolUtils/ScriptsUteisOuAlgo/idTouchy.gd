extends TouchScreenButton
class_name IdTouchy

@export var id:int = 0
var isPressed:bool = false
signal doThing(id:int)
signal doThingHold(id:int)

func _ready() -> void:
	pressed.connect(func():
		doThingHold.emit(id)
		if not isPressed:
			isPressed = true
			doThing.emit(id)
			)
	
	released.connect(func():
		isPressed = false
		)
