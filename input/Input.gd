extends LineEdit

@export var max_history = 1000
var history:Array[String] = []
var history_idx = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grab_focus()


func _on_Input_text_entered(new_text: String) -> void:
	clear()
	#this could get slow with large buffers. consider using a circular buffer if that happens
	history.push_front(new_text)
	if len(history) > max_history:
		history.pop_back()
	history_idx = -1 #move the history marker back to the start

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		get_viewport().set_input_as_handled()
		search_history_up()
	if event.is_action_pressed("ui_down"):
		get_viewport().set_input_as_handled()
		search_history_down()
	
		
"""	if event is InputEventKey:
		if event.keycode == KEY_UP:
			if event.pressed:	search_history_up()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_DOWN:
			if event.pressed:	search_history_down()
			get_viewport().set_input_as_handled()
"""
#go up through the history finding matches with the string prior to the caret
func search_history_up():
	var idx = history_idx + 1
	var column = caret_column
	var match_string :String = text.left(caret_column)

	#search
	while idx < len(history):
		if history[idx].begins_with(match_string) and history[idx] != text: #skip identical texts
			break
		idx += 1
	
	#check results
	if idx < len(history):# and idx != history_idx:
		text = history[idx]
		caret_column = column
		history_idx = idx
		select(caret_column)
	
		
	#print("History idx: ", history_idx)
		
#go down through the history finding matches with the string prior to the caret
func search_history_down():
	var idx = history_idx -1
	var column = caret_column
	var match_string :String = text.left(caret_column)
	
	while idx >= 0:
		if history[idx].begins_with(match_string) and history[idx] != text: #skip identical texts
			break
		idx -= 1
		
	if idx >= 0:# and idx != history_idx:
		text = history[idx]	#update the text and history position
		caret_column = column
		history_idx = idx
		select(caret_column) #select the historical text so it can be overwritten
	else:
		# clear history (highlighted text after the caret) if at the bottom of the list
		history_idx = -1
		text = match_string
		caret_column = column
		
	#print("History idx: ", history_idx)
