extends Button
class_name CommandButton

#@export var command :String
@export var next_selector: String #if null, will immedieately enter the command
signal enter_command(command, next)

func _on_press():
	var cmd_string = text.to_lower() + " "
	enter_command.emit(cmd_string, next_selector)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_press)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
