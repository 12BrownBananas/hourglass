extends MenuSelect

var action_buttons: Array[Button];
var action_select_button_prefab = load("res://scenes/ui_components/action_select_button.tscn");

func add_actions(action_list: Array[GameManager.PlayerAction]):
	for action in action_list:
		var button: ActionSelectButton = action_select_button_prefab.instantiate();
		button.set_action(action);
		action_buttons.append(button);
		button.pressed.connect(button.on_pressed);
		_scrollbox_button_area.add_child(button);
	queue_redraw();
	
func clear_actions():
	for button in action_buttons:
		remove_child(button);
	action_buttons.clear();
	queue_redraw();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	action_buttons = [];
	destination = out_position;
