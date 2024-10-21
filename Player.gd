extends Node
class_name Player

var inventory: Array[Item] = []


func take_item(item: Item):
	inventory.append(item)


func drop_item(item: Item):
	inventory.erase(item)

func get_item(item_name:String)->Item:
	item_name = item_name.to_lower()
	for item in inventory :
		if item.item_name.to_lower() == item_name:
			return item
	return null

func get_basic_inventory_list()->Array[String]:
	var list :Array[String] = []
	for item in inventory:
		list.append(item.item_name.to_lower())
	return list
	
func get_inventory_list() -> String:
	if inventory.size() == 0:
		return "You don't currently have anything."

	var item_string = ""
	for item in inventory:
		item_string += item.item_name + " "
	return "Inventory: " + item_string
