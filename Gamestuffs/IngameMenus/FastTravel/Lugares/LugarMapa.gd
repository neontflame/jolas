extends Node2D
class_name LugarMapa

static var mapaCoiso
static var instance

var curSelected:int = 0
var canSelect:bool = true

var thePins:Array = []

func _enter_tree() -> void:
	LugarMapa.instance = self

func _ready() -> void:
	thePins = $Pins.get_children()
	setup_pins()
	whereAmI()
	$PlaceName.text = GameUtils.get_map_info(get_pin(curSelected).placeId)['name']
	$RegName.text = GameUtils.get_map_info(get_pin(curSelected).placeId)['region']

func change_self_scene(coolscene:String):
	if Submenu.saveMenu: Submenu.saveMenu.queue_free()
	Submenu.saveMenu = load(coolscene).instantiate()
	get_parent().add_child(Submenu.saveMenu)
	Submenu.saveMenu.z_index = z_index
	call_deferred('queue_free')
	
func _process(delta: float) -> void:
	if get_pin(curSelected) == null: return
	$PlaceGoThing.position = $PlaceGoThing.position.lerp(
							get_pin(curSelected).position, 
							0.2)
	
	if canSelect:
		if len(thePins) > 0:
			if Input.is_action_just_pressed("ui_left"):
				goToOtherPin(curSelected, 'LEFT')
			if Input.is_action_just_pressed("ui_up"):
				goToOtherPin(curSelected, 'UP')
			if Input.is_action_just_pressed("ui_down"):
				goToOtherPin(curSelected, 'DOWN')
			if Input.is_action_just_pressed("ui_right"):
				goToOtherPin(curSelected, 'RIGHT')
		if Input.is_action_just_pressed("ui_accept"):
			CoolMenu.play_sfx('Go')
			canSelect = false
			Submenu.instance.goToThing(get_pin(curSelected).placeId)

#region Pin utils
func setup_pins():
	for pin in thePins:
		for key in pin.goto.keys():
			if pin.goto[key].is_valid_int() && pin.goto[key] != '-1':
				if get_pin(int(pin.goto[key])) == null:
					pin.goto[key] = '-1'

func whereAmI():
	thePins = $Pins.get_children()
	for pin in thePins:
		if pin.placeId == GPStats.curMap:
			curSelected = pin.coolId

func get_pin(thepin:int):
	thePins = $Pins.get_children()
	for pin in thePins:
		if pin.coolId == thepin:
			return pin
	return null

func goToOtherPin(thepin:int, where:String):
	var myPin = get_pin(thepin)
	print(myPin.goto)
	
	if myPin.goto[where] != '-1':
		if myPin.goto[where].is_valid_int():
			curSelected = int(myPin.goto[where])
			$PlaceName.text = GameUtils.get_map_info(get_pin(curSelected).placeId)['name']
			$RegName.text = GameUtils.get_map_info(get_pin(curSelected).placeId)['region']
			CoolMenu.play_sfx('Tick')
		else:
			changeMap(myPin.goto[where])
			CoolMenu.play_sfx('Tick')
#endregion

func changeMap(mapName:String):
	var lugarpath:String = "res://Gamestuffs/IngameMenus/FastTravel/Lugares/%s.tscn" % mapName
	if LugarMapa.mapaCoiso: LugarMapa.mapaCoiso.queue_free()
	LugarMapa.mapaCoiso = load(lugarpath).instantiate()
	get_parent().add_child(LugarMapa.mapaCoiso)
	LugarMapa.mapaCoiso.global_position = global_position
	LugarMapa.mapaCoiso.z_index = z_index
	call_deferred('queue_free')
