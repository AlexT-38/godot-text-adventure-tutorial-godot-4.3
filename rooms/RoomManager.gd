extends Node


func _ready() -> void:
	#connect exits and keys
	#we probably want to allow for one way exits, one way locks, etc. but for now we recreate the existing functionality
	#one way items would likely need a complete rework of the exit class.
	#the map is a doubly linked list/directed cyclic graph.
	#creating one way exits is simple to implement by treating an exit as a room property, rather than a connector class
	#one way locks are also easy to implement, but standard locks require communication between the two complementary exits
	#setting up could be error prone, since we'd have to set complementary exits independantly
	#maybe that could be helped by only allowing non-complementary directions to be one way
	
	for room in get_children():							#go through each child
		if room is GameRoom:							#find rooms
			#print out the object id's for all npcs and items in the room for comparison later
			if room.items.size() > 0:
				print(room.name," items:")
				for item in room.items:
					print("> ",item)
			if room.npcs.size() > 0:
				print(room.name," NPCs:")
				for npc in room.npcs:
					print("> ",npc)
					if npc.quest_item:
						print(">> ",npc.quest_item)
						
			for direction in room.exit_rooms.keys():	#go through each exit
				
				#check the other room exists
				var other_room = room.get_node(room.exit_rooms[direction])
				if not other_room:
					printerr("Null found when ",room.name," attempted to connect to ",room.exit_rooms[direction]," in direction ",direction)
					continue
					
				#check that exit hasn't already been created from another room
				if direction in room.exits:
					print("INFO: ",room.name," already has exit for ",direction)
					#we should probably check that the exit goes the same place and throw an error if not
					var exit :Exit = room.exits[direction]
					var check_room :GameRoom = exit.get_other_room(room)
					if  check_room != other_room:
						printerr("Existing exit, ",direction," to ",check_room.name,", does not match specified exit to ",other_room.name)
					continue
					
				#check for non standard directions
				var return_dir = GameRoom.get_return_dir(direction) #returns null when no complementary direction defined
				if return_dir == "null":
					#use the same dir name by default
					return_dir = direction 
					#try to fetch name from other room
					for other_dir in other_room.exit_rooms.keys():
						if other_room.get_node(other_room.exit_rooms[other_dir]) == room:	#got it
							return_dir = other_dir
							break
							
				#check for locking objects
				if direction in room.exit_keys.keys():
					var key = room.exit_keys[direction]
					#check this is a valid key type
					if key is not Item and key is not NPC:
						printerr(room.name,": ",direction," exit key item is not item or NPC: ",key," (",typeof(key),")")
						#create an unlocked door if the key is not of an expoected type
						room.connect_exit_unlocked(direction, other_room, return_dir)
					else:
						#create locked exit and assign exit to locking object
						var exit = room.connect_exit_locked(direction, other_room, return_dir)
						print("key: ",key)
						if key is Item:
							key.use_value = exit
							if key.item_type != Types.ItemTypes.KEY:
								printerr("key ",key.name," for exit ",room.name,"[",direction,"] is not a key item type")
						elif key is NPC:
							key.quest_reward = exit
							print(key.quest_reward)
				else:
					#create exit
					room.connect_exit_unlocked(direction, other_room, return_dir)
					


func load_item(item_name: String):
	return load("res://items/" + item_name + ".tres")


func load_npc(npc_name: String):
	return load("res://npcs/" + npc_name + ".tres")
