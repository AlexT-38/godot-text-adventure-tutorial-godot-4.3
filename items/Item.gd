extends Resource
class_name Item


@export var item_name := "Item Name"
@export var item_type := Types.ItemTypes.KEY # (Types.ItemTypes)
@export var item_description = "There is nothing special about its appearance."
@export var consume_on_use = true
var use_value = null
