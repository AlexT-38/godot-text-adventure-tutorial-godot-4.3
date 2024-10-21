extends ScrollContainer
class_name ListSelector
#populate the list with the appropriate strings
const SELECTBUTTON = preload("res://input/selector_button.tscn")

@onready var list :Node = $ListRows
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
	for item in list_items:
		var button = SELECTBUTTON.instantiate()
		button.name = item
		button.text = item
		list.add_child(button)
		button.enter_command.connect(select)

func select(item, next):
	on_select.emit(item, next)
		
	
