extends Button
class_name ActionSelectButton;

@export var label: Label;
var action: GameManager.PlayerAction;

func set_action(action_to_set: GameManager.PlayerAction) -> void:
	action = action_to_set;
	label.text = action.get_name();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func on_pressed():
	action.invoke();
