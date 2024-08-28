extends MenuSelect

var item_buttons: Array[Button];
var item_select_button_prefab = load("res://scenes/ui_components/item_select_button.tscn");

func add_items(item_list: Array[ItemLookup.Item]):
	for item in item_list:
		var button: ItemSelectButton = item_select_button_prefab.instantiate();
		button.icon = item._appearance._sprite;
		button.set_name_label(item.get_name());
		button.set_durability_label(item._stats._uses, item._stats._remaining_uses);
		item_buttons.append(button);
		_scrollbox_button_area.add_child(button);
	queue_redraw();
	
func clear_items():
	for button in item_buttons:
		remove_child(button);
	item_buttons.clear();
	queue_redraw();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_buttons = [];
	destination = out_position;
