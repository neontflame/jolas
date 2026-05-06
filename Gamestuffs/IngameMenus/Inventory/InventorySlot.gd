extends Control
class_name InventorySlot

@export var id:int = 0
@export var item:String = ""

func setup(index:int):
	#todo: fazer utils de item e renderizar itens
	item = ""
	$Label.visible = false
	if index < len(InventoryUtils.inventory):
		$CoolIcon.texture = GameUtils.get_item_asset(InventoryUtils.inventory[index][0], "Icon.png")
		if InventoryUtils.inventory[index][1] > 1:
			$Label.visible = true
			$Label.text = 'x' + str(int(InventoryUtils.inventory[index][1]))
		item = InventoryUtils.inventory[index][0]
