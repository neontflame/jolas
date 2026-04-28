extends Node2D
@export var diagShitsContainer:VBoxContainer
@export var theScroll:ScrollContainer
var coolTweenie:Tween

func _on_diag_load_pressed() -> void:
	for child in diagShitsContainer.get_children():
		diagShitsContainer.remove_child(child)
	var pathness = 'res://Gamestuffs/Dialoguestuffs/Dialogues/' + $CanvasLayer/Control2/dialogueName.text + '.json'
	var theJayson:Dictionary = JSON.parse_string(FileUtils.get_text_file_content(pathness))
	if theJayson.has('questClear'):
		$CanvasLayer/Control/questClear.text = theJayson['questClear']
	if theJayson.has('questAssigned'):
		$CanvasLayer/Control/questAssigner.text = theJayson['questAssigned']
	var idcool:int = 0
	for linery in theJayson['dialogue']:
		idcool += 1
		var line = theJayson['dialogue']['line' + str(idcool)]
		var newThingie = load("res://Gamestuffs/Dialoguestuffs/Editor/DiagEdFragment.tscn").instantiate()
		diagShitsContainer.add_child(newThingie)
		newThingie.setup(line)
		newThingie.id = idcool
		newThingie.moveUp.connect(moveDiagUp)
		newThingie.moveDown.connect(moveDiagDown)
		newThingie.delete.connect(deleteDiag)
	refreshIndexes()

func _on_add_diag_pressed() -> void:
	var newThingie = load("res://Gamestuffs/Dialoguestuffs/Editor/DiagEdFragment.tscn").instantiate()
	diagShitsContainer.add_child(newThingie)
	newThingie.moveUp.connect(moveDiagUp)
	newThingie.moveDown.connect(moveDiagDown)
	newThingie.delete.connect(deleteDiag)
	refreshIndexes()

func moveDiagUp(diag):
	diagShitsContainer.move_child(diag, diag.get_index() - 1)
	refreshIndexes()
	
	if coolTweenie: coolTweenie.kill()
	coolTweenie = get_tree().create_tween()
	coolTweenie.set_ease(Tween.EASE_OUT)
	coolTweenie.tween_property(theScroll, "scroll_vertical", diag.position.y, 0.1)

func moveDiagDown(diag):
	diagShitsContainer.move_child(diag, diag.get_index() + 1)
	refreshIndexes()
	
	if coolTweenie: coolTweenie.kill()
	coolTweenie = get_tree().create_tween()
	coolTweenie.set_ease(Tween.EASE_OUT)
	coolTweenie.tween_property(theScroll, "scroll_vertical", diag.position.y, 0.1)

func deleteDiag(diag):
	diag.delete.disconnect(deleteDiag)
	await diag.queue_free()
	refreshIndexes()

func refreshIndexes():
	var idcool:int = 0
	for child in diagShitsContainer.get_children():
		idcool += 1
		child.id = idcool

func getJson() -> Dictionary:
	var dictio:Dictionary = {
		"questAssigned": "",
		"questClear": "",
		"dialogue": {}
	}
	
	dictio["questClear"] = $CanvasLayer/Control/questClear.text
	dictio["questAssigned"] = $CanvasLayer/Control/questAssigner.text
	for child in diagShitsContainer.get_children():
		var jso:Dictionary = child.makeJson()
		dictio["dialogue"]["line" + str(child.id)] = jso
		
	return dictio

func _on_copy_2_clipboard_pressed() -> void:
	var theJays:Dictionary = getJson()
	DisplayServer.clipboard_set(JSON.stringify(theJays, "\t"))
