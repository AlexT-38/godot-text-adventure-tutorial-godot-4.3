extends MarginContainer
class_name CommandSelector

signal add_string_to_input(string)
signal clear_input()
signal enter_input()
signal fetch_list(list_name, callback)


@onready var buttons = $VBoxContainer/CommandButtons
@onready var list_selector :ListSelector = $VBoxContainer/ListSelector
var selector

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect list selector signal
	list_selector.on_select.connect(process_command)
	# connect button signals
	for child in buttons.get_children():
		if child is CommandButton:
			child.enter_command.connect(process_command)
		elif child is Button:
			child.pressed.connect(clear_command)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func process_command(cmd, next_selector):
	add_string_to_input.emit(cmd)
	if next_selector == "":
		reset_selector()
		enter_input.emit()
	else:
		selector = next_selector
		fetch_list.emit(selector, list_selector.set_list)
		list_selector.show()
		disable_cmd_buttons()

func disable_cmd_buttons():
	for child in buttons.get_children():
		if child is CommandButton:
			child.disabled = true

func enable_cmd_buttons():
	for child in buttons.get_children():
		if child is CommandButton:
			child.disabled = false

func clear_command():
	reset_selector()
	clear_input.emit()
	
func reset_selector():
	list_selector.hide()
	selector = ""
	enable_cmd_buttons()
