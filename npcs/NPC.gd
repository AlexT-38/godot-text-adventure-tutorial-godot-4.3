extends Resource
class_name NPC


@export var npc_name: String = "NPC Name"
@export var npc_description :String = "There is nothing special about their appearance."

@export var initial_dialog : String # (String, MULTILINE)
@export var subsequent_dialog : String
@export var post_quest_dialog: String # (String, MULTILINE)
@export var subsequent_post_quest_dialog : String

@export var quest_item: Resource

var has_received_quest_item := false
var quest_reward = null
var has_given_quest :bool = false
var has_given_reward :bool = false

func get_dialog()->String:
	var dialog:String = ""
	if has_received_quest_item:
		if has_given_reward:
			dialog = subsequent_post_quest_dialog
		else:
			dialog = post_quest_dialog
			if subsequent_post_quest_dialog != "": has_given_reward = true
	else:
		if has_given_quest:
			dialog = subsequent_dialog
		else:
			dialog = initial_dialog
			if subsequent_dialog != "": has_given_quest = true
			
	return dialog
	
