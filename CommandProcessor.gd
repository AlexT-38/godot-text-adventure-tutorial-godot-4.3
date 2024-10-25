extends Node


signal room_changed(new_room)
signal room_updated(current_room)

var current_room :GameRoom = null
var player :Player = null
@export var infer_go = false
@export var infer_take = true
@export var infer_use = true
@export var infer_drop = true
@export var infer_talk = true
@export var infer_give = true

func initialize(starting_room, player) -> String:
	self.player = player
	return change_room(starting_room)

func process_command(input: String) -> String:
	var words = input.split(" ", false)
	if words.size() == 0:
		return "Error: no words were parsed."

	var first_word = words[0].to_lower()
	var second_word = ""
	if words.size() > 1:
		second_word = words[1].to_lower()

	match first_word:
		"go":
			return go(second_word)
		"take":
			return take(second_word)
		"drop":
			return drop(second_word)
		"inventory":
			return inventory()
		"use":
			return use(second_word)
		"talk":
			return talk(second_word)
		"give":
			return give(second_word)
		"examine":
			return examine(second_word)
		"help":
			return help()
		_:
			#make life easier by infering commands
			var response = match_direction(first_word)
			if response != "":
				return response
			response = match_item(first_word)
			if response != "":
				return response
			return Types.wrap_system_text("Unrecognized command - please try again.")

func examine(object_name:String)->String:
	if object_name == "":
		return current_room.get_full_description()#Types.wrap_system_text("Examine what?")
	#check inventory, then room items, then npcs
	var thing_to_examine = player.get_item(object_name)
	if thing_to_examine:
		return Types.wrap_item_text(thing_to_examine.item_name)+": "+thing_to_examine.item_description
		
	thing_to_examine = current_room.get_item(object_name)
	if thing_to_examine:
		return Types.wrap_item_text(thing_to_examine.item_name)+": "+thing_to_examine.item_description
	
	thing_to_examine = current_room.get_npc(object_name)
	if thing_to_examine:
		return Types.wrap_npc_text(thing_to_examine.npc_name)+": "+thing_to_examine.npc_description
	
	return "There is no "+object_name+" to examine."
	
# use an item in inventory or take an item in the current room
# without needing to specify the use/take commang
func match_item(item_name:String)->String:
	if player.get_item(item_name): return use(item_name)
	if current_room.get_item(item_name): return take(item_name)
	return ""

# go in the direction given without needing to specify the go command
# also recognise a single letter matching the direction name's first letter
func match_direction(direction:String)->String:
	if current_room.exits.keys().has(direction):
		return go(direction)
	for exit in current_room.exits.keys():
		if exit[0] == direction:
			return go(exit)
	return ""
		
func go(second_word: String) -> String:
	# handle infered direction selection
	if second_word == "":
		if len(current_room.exits) == 0:
			return Types.wrap_system_text("There is no where to go.")
		elif len(current_room.exits) == 1 and infer_go:
			second_word = current_room.exits.keys()[0]
		else: return Types.wrap_system_text("Go where?")

	if current_room.exits.keys().has(second_word):
		var exit = current_room.exits[second_word]
		if exit.is_locked:
			return "The way " + Types.wrap_location_text(second_word) + " is currently " + Types.wrap_system_text("locked!")
		var change_response = change_room(exit.get_other_room(current_room))
		return "\n".join(PackedStringArray(["You go " + Types.wrap_location_text(second_word) + ".", change_response]))
	else:
		return "This room has no " + Types.wrap_location_text(second_word) + " exit."


func take(second_word: String) -> String:
	var item_to_take :Item = null
	# handle infered item selection
	if second_word == "":
		if len(current_room.items) == 0:
			return Types.wrap_system_text("There is nothing to take.")
		elif len(current_room.items) == 1 and infer_take:
			item_to_take = current_room.items[0]
			second_word = item_to_take.item_name
		else:	return Types.wrap_system_text("Take what?")
		
	if item_to_take == null:
		item_to_take =current_room.get_item(second_word)
				
	if item_to_take != null:
		current_room.remove_item(item_to_take)
		player.take_item(item_to_take)
		emit_signal("room_updated", current_room)
		return "You take the " + Types.wrap_item_text(second_word) + "."

	return "There is no " + Types.wrap_item_text(second_word) + " here."


func drop(second_word: String) -> String:
	var item_to_drop :Item = null
	#handle infered item selection
	if second_word == "":
		if len(player.inventory) == 0:
			return Types.wrap_system_text("You have nothing to drop.")
		elif len(player.inventory) == 1 and infer_drop:
			item_to_drop = player.inventory[0]
		return Types.wrap_system_text("Drop what?")

	if not item_to_drop:
		item_to_drop = player.get_item(second_word)
		
	if item_to_drop: 
		player.drop_item(item_to_drop)
		current_room.add_item(item_to_drop)
		emit_signal("room_updated", current_room)
		return "You drop the " + Types.wrap_item_text(item_to_drop.item_name) + "."
	
	return "You don't have anything called " + Types.wrap_item_text(second_word) + "."


func inventory() -> String:
	return player.get_inventory_list()


func use(second_word: String) -> String:
	var item_to_use :Item = null
	#handle infered item selection
	if second_word == "":
		if len(player.inventory) == 0:
			return Types.wrap_system_text("You have nothing to use.")
		if len(player.inventory) == 1 and infer_use:
			item_to_use = player.inventory[0]
			second_word = item_to_use.item_name
		else: return Types.wrap_system_text("Use what?")

	if not item_to_use:
		item_to_use = player.get_item(second_word)
		
	if item_to_use:
		match item_to_use.item_type:
			Types.ItemTypes.KEY:
				for exit in current_room.exits.values():
					if exit == item_to_use.use_value:
						
						if item_to_use.consume_on_use:
							exit.is_locked = false
							player.drop_item(item_to_use)
						else:
							exit.is_locked = not exit.is_locked
							
						var lock_state = "lock" if exit.is_locked else "unlock"
							
						return "You use a " + Types.wrap_item_text(second_word) + " to " + lock_state + " the way to " + Types.wrap_location_text(exit.get_other_room(current_room).room_name) + "."
				return "Your " + Types.wrap_item_text(second_word) + " does not unlock anything here."
			_:
				return "Error - tried to use an item with an invalid type."

	return "You don't have a " + Types.wrap_item_text(second_word) + "."


func talk(second_word: String) -> String:
	var npc_to_talk_to :NPC = null
	#infer npc to talk to
	if second_word == "":
		if len(current_room.npcs) == 0:
			return Types.wrap_system_text("There is no one to talk to.")
		if len(current_room.npcs) == 1 and infer_talk:
			npc_to_talk_to = current_room.npcs[0]
		else:	return Types.wrap_system_text("Talk to who?")
	#find the npc in the room
	if not npc_to_talk_to:
		npc_to_talk_to = current_room.get_npc(second_word)
	#fetch and print the dialog, if available
	if npc_to_talk_to:
		var dialog = npc_to_talk_to.get_dialog()
		return Types.wrap_npc_text(npc_to_talk_to.npc_name + ": ") + Types.wrap_speech_text("\"" + dialog + "\"")

	return "There is no " + Types.wrap_npc_text(second_word) + " here."


func give(second_word: String) -> String:
	var item_to_give :Item
	#handle infered item selection
	if second_word == "":
		if len(player.inventory) == 0:
			return Types.wrap_system_text("You have nothing to give.")
		elif len(player.inventory) == 1 and infer_give:
			item_to_give = player.inventory[0]
		else:
			return Types.wrap_system_text("Give what?")

	for item in player.inventory:
		if second_word.to_lower() == item.item_name.to_lower():
			item_to_give = item
			break

	if not item_to_give:
		return "You don't have a " + Types.wrap_item_text(second_word) + "."

	for npc in current_room.npcs:
		if npc.quest_item != null and second_word.to_lower() == npc.quest_item.item_name.to_lower():
			npc.has_received_quest_item = true

			if npc.quest_reward != null:
				var reward = npc.quest_reward
				if "is_locked" in reward:
					reward.is_locked = false
				else:
					printerr("Warning - tried to have a quest reward type that is not implemented.")

			player.drop_item(item_to_give)
			return "You give the " + Types.wrap_item_text(second_word) + " to the " +  Types.wrap_npc_text(npc.npc_name) + "."

	return "Nobody here wants a" + Types.wrap_item_text(second_word) + "."


func help() -> String:
	return "\n".join( PackedStringArray([
		"You can use these commands: ",
		" go " + Types.wrap_location_text("[location]"),
		" take " + Types.wrap_item_text("[item]"),
		" drop " + Types.wrap_item_text("[item]"),
		" use " + Types.wrap_item_text("[item]"),
		" talk " + Types.wrap_npc_text("[npc]"),
		" give " + Types.wrap_item_text("[item]"),
		" examine " + Types.wrap_item_text("[item]") + "|" + Types.wrap_npc_text("[npc]") ,
		" inventory",
		" help"
	]  ))


func change_room(new_room: GameRoom, exit:Exit=null) -> String:
	if current_room: current_room.on_exit(exit)
	current_room = new_room
	new_room.on_entry(exit)
	room_changed.emit(new_room)
	return new_room.get_full_description()
