extends Node
class_name InventoryUtils

static var inventory:Array = [] # ['nomeDoItem', quantia em int] 

static func add_to_inventory(item:String, amount:int = 1):
	for _item in inventory:
		if _item[0] == item:
			_item[1] += amount
			return
	inventory.append([item, amount])

static func remove_from_inventory(item:String, amount:int = 1):
	for _item in inventory:
		if _item[0] == item:
			if _item[1] > amount:
				_item[1] -= amount
			else:
				inventory.erase(_item)

static func has_item_in_inventory(item:String, amount:int = 1):
	for _item in inventory:
		if _item[0] == item:
			if _item[1] >= amount:
				return true
	return false
