extends Resource
class_name NPC


@export var npc_name: String = "NPC Name"

@export var initial_dialog : String # (String, MULTILINE)
@export var post_quest_dialog: String # (String, MULTILINE)

@export var quest_item: Resource

var has_received_quest_item := false
var quest_reward = null
