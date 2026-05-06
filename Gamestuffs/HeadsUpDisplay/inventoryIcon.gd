extends Sprite2D

func _enter_tree() -> void:
	$RichTextLabel.bbcode_enabled = true
	$RichTextLabel.text = GeneralUtils.text_replacery("ctrl_inventory") + ' '

func _process(_delta: float) -> void:
	$InventoryCount.visible = (len(InventoryUtils.inventory) > 0)
	$InventoryCount/Label.text = str(len(InventoryUtils.inventory))

func rerenderCtrl():
	$RichTextLabel.text = GeneralUtils.text_replacery("ctrl_inventory") + ' '
