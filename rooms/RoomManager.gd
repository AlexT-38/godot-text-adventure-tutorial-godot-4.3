extends Node


func _ready() -> void:
	var key = Item.new()
	key.initialize("Key", Types.ItemTypes.KEY)

	$HouseRoom.connect_exit("east", $OutsideRoom)
	$HouseRoom.add_item(key)
