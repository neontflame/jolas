extends Sprite2D

func _ready() -> void:
	$GoBack.text = GeneralUtils.text_replacery($GoBack.text)

func renderItem(invIndex:int):
	$InventorySlot.setup(invIndex)
	$InventorySlot.get_node('Label').visible = false
	var itemName = InventoryUtils.inventory[invIndex][0]
	$ItemName.text = GameUtils.get_item_info(itemName)['name']
	$ItemContent.text = GameUtils.get_item_info(itemName)['desc']
	$ItemContent.get_v_scroll_bar().value = 0

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		$ItemContent.get_v_scroll_bar().value -= 2
		
	if Input.is_action_pressed("ui_down"):
		$ItemContent.get_v_scroll_bar().value += 2
