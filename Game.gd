extends Control


@onready var game_info = $Background/MarginContainer/Columns/Rows/GameInfo
@onready var command_processor = $CommandProcessor
@onready var room_manager = $RoomManager
@onready var player = $Player
@onready var input = $Background/MarginContainer/Columns/Rows/InputArea/HBoxContainer/Input


func _ready() -> void:
	var side_panel = $Background/MarginContainer/Columns/VBoxContainer/SidePanel
	command_processor.connect("room_changed", Callable(side_panel, "handle_room_changed"))
	command_processor.connect("room_updated", Callable(side_panel, "handle_room_updated"))

	game_info.create_response(Types.wrap_system_text("Welcome to the retro text adventure! You can type 'help' to see available commands."))

	var starting_room_response = command_processor.initialize(room_manager.get_child(0), player)
	game_info.create_response(starting_room_response)
	
	var command_selector :CommandSelector = $Background/MarginContainer/Columns/VBoxContainer/CommandSelector
	
	command_selector.add_string_to_input.connect(append_input)
	command_selector.clear_input.connect(clear_input)
	command_selector.enter_input.connect(enter_input)
	command_selector.fetch_list.connect(fetch_list)



func _on_Input_text_entered(new_text: String) -> void:
	if new_text.is_empty():
		return

	var response = command_processor.process_command(new_text)
	game_info.create_response_with_input(response, new_text)

#provide some mechanisms for script controlled input text entry
func clear_input():
	input.clear()
	input.grab_focus()
	
func append_input(string:String):
	input.text += string
	input.grab_focus()
	input.caret_column = len(input.text)

func enter_input():
	_on_Input_text_entered(input.text)
	input._on_Input_text_entered("")
	input.grab_focus()
	
#provide some mechanisms for fetching npcs, items, directions, inventory
func fetch_list(list_name:String, callback:Callable)->void:
	var list = []
	match list_name:
		"NPCs":
			list = command_processor.current_room.get_npc_list()
		"Directions":
			list = command_processor.current_room.get_exits_list()
		"Items":
			list = command_processor.current_room.get_items_list()
		"Inventroy":
			list = player.get_basic_inventory_list()
	callback.call(list)
