extends ScrollContainer
class_name ListSelector
#populate the list with the appropriate strings
const SELECTBUTTON = preload("res://input/selector_button.tscn")

#set true to automatically select from a single item list
@export var auto_complete = {"NPCs":false,"Directions":false,"Items":false,"Inventory":false,"AnyItem":false,"AnyEntity":false} 
 #set true to automatically select from an empty list
@export var auto_complete_empty = {"NPCs":true,"Directions":true,"Items":true,"Inventory":true,"AnyItem":true,"AnyEntity":true}
@onready var list :Node = $ListRows
var selector :String = ""

signal on_select(selection, next)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_list(list_items:Array[String]):
	for child in list.get_children():
		child.queue_free()
	if len(list_items) == 0 and auto_complete_empty[selector]:
		select("","")
		return
	if len(list_items) == 1 and auto_complete[selector]:
		select(list_items[0],"")
		return
		
	for item in list_items:
		var button = SELECTBUTTON.instantiate()
		button.name = item
		button.text = item
		list.add_child(button)
		button.enter_command.connect(select)

func select(item, next):
	on_select.emit(item, next)
		
	
