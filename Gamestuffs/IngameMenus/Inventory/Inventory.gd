extends Sprite2D

@export var itemsContainer:GridContainer
@export var pageLabel:Label
var curPage:int = 1
var maxPage:int = 1
var coolSlots:Array[InventorySlot] = []

@export var rightArrow:AnimatedSprite2D
@export var leftArrow:AnimatedSprite2D

@export var selectIndicator:AnimatedSprite2D

var pageRendered:bool = false
var active:bool = true

func _ready() -> void:
	maxPage = max(ceil(len(InventoryUtils.inventory) / 28.0), 1)
	for label in [rightArrow.get_node('Label'), leftArrow.get_node('Label')]:
		label.text = GeneralUtils.text_replacery(label.text)

	rightArrow.animation_finished.connect(func():
		if rightArrow.animation == 'press':
			rightArrow.play("default")
		)
	leftArrow.animation_finished.connect(func():
		if leftArrow.animation == 'press':
			leftArrow.play("default")
		)
		
	renderPage()

func _physics_process(delta: float) -> void:
	if not pageRendered: 
		return
	selectIndicator.global_position = lerp(
								selectIndicator.global_position, 
								coolSlots[CoolMenu.curSelected].global_position + Vector2(32.0, 32.0), 
								0.5)
	
	if not active: return
	if Input.is_action_just_pressed("ui_left"):
		CoolMenu.play_sfx('Tick')
		CoolMenu.curSelected = clamp(CoolMenu.curSelected - 1, 0, 27)
	if Input.is_action_just_pressed("ui_right"):
		CoolMenu.play_sfx('Tick')
		CoolMenu.curSelected = clamp(CoolMenu.curSelected + 1, 0, 27)
	if Input.is_action_just_pressed("ui_down"):
		if (CoolMenu.curSelected + 7) <= 27:
			CoolMenu.play_sfx('Tick')
			CoolMenu.curSelected = clamp(CoolMenu.curSelected + 7, 0, 27)
	if Input.is_action_just_pressed("ui_up"):
		if (CoolMenu.curSelected - 7) >= 0:
			CoolMenu.play_sfx('Tick')
			CoolMenu.curSelected = clamp(CoolMenu.curSelected - 7, 0, 27)
	
	if Input.is_action_just_pressed("ui_prev_page"):
		if curPage != 1:
			CoolMenu.play_sfx('Tick')
			leftArrow.play("press")
			renderPage(clamp(curPage - 1, 1, maxPage))
		
	if Input.is_action_just_pressed("ui_next_page"):
		if curPage != maxPage:
			CoolMenu.play_sfx('Tick')
			leftArrow.play("press")
			renderPage(clamp(curPage + 1, 1, maxPage))

func renderPage(page:int = 1):
	# 28 itens por pagina
	CoolMenu.curSelected = 0
	pageRendered = false
	curPage = page
	var pageIndex = (page - 1) * 28
	coolSlots = []
	for child in itemsContainer.get_children():
		child.queue_free()
	
	for it in range(28):
		var slot:InventorySlot = load("res://Gamestuffs/IngameMenus/Inventory/InventorySlot.tscn").instantiate()
		slot.setup(it + pageIndex)
		slot.id = it
		itemsContainer.add_child(slot)
		coolSlots.append(slot)
		
	curPageText()
	leftArrow.visible = (curPage != 1)
	rightArrow.visible = (curPage != maxPage)
	pageRendered = true

func curPageText():
	pageLabel.text = "Página %s de %s" % [curPage, maxPage]
